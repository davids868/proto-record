# frozen_string_literal: true

require "active_support/concern"

require "proto_record/errors"

module ProtoRecord
  extend ActiveSupport::Concern

  module ClassMethods
    attr_writer :proto_message, :proto_options, :proto_message_fields

    def proto_message(message = nil, options = {})
      unless message.nil?
        @proto_message = message.to_s.classify.constantize
        self.proto_options = options
        self.proto_message_fields = @proto_message.new.to_h.keys.map(&:to_s)
      end

      if @proto_message.nil? && superclass.respond_to?(:proto_message)
        @proto_message ||= superclass.proto_message
      end

      @proto_message
    end

    def proto_options
      @proto_options ||= {}
    end

    def proto_message_fields
      @proto_message_fields ||= []
    end
  end

  def to_proto
    raise MissingProtoMessage, self.class.name if proto_message.nil?
    message_args = is_a?(ActiveRecord::Base) ? resolve_active_record_object : resolve_class_object

    message_args = transform_date_values(message_args)
    message_args = transform_class_attributes(message_args)

    proto_message.new(message_args)
  end

  private

  def proto_options
    self.class.proto_options
  end

  def proto_message
    self.class.proto_message
  end

  def proto_fields
    self.class.proto_message_fields
  end

  def resolve_class_object
    resolver = self.class.proto_options[:fields_resolver]

    raise MissingFieldsResolver, self.class if resolver.nil?

    send(resolver)
  end

  def resolve_active_record_object
    intersecting_attributes = proto_fields & attribute_names
    intersecting_associations = proto_fields - attribute_names

    resolved_attributes = attributes.slice(*intersecting_attributes)
    resolved_associations = intersecting_associations.map(&method(:resolve_association)).to_h

    resolved_attributes.merge(resolved_associations)
  end

  def resolve_association(field)
    res = try(field)
    reflection = self.class.reflect_on_association(field)

    unless reflection.nil? || res.nil?
      res = reflection.collection? ? res.map(&:to_proto) : res.to_proto
    end

    [field, res]
  end

  def transform_class_attributes(hash)
    hash.transform_values { |value| value.respond_to?(:to_proto) ? value.to_proto : value }
  end

  def transform_date_values(hash)
    hash.transform_values { |value| value.respond_to?(:strftime) ? value.to_time : value }
  end
end