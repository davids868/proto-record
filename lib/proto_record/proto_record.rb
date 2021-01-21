# frozen_string_literal: true

require "active_support/concern"

require "proto_record/errors"

module ProtoRecord
  extend ActiveSupport::Concern

  included do
    class << self
      def proto_message(message = nil, options = {})
        unless message.nil?
          @proto_message = message.to_s.classify.constantize
          @proto_options = options
        end

        @proto_message ||= superclass.proto_message if @proto_message.nil? && superclass.respond_to?(:proto_message)

        @proto_message
      end

      def proto_options
        @proto_options ||= {}
      end

      def proto_message_fields
        @proto_message_fields = @proto_message.new.to_h.keys.map(&:to_s)
      end
    end
  end

  def to_proto
    raise MissingProtoMessage, self.class.name if proto_message.nil?

    message_args = is_a?(ActiveRecord::Base) ? resolve_active_record_object : resolve_class_object

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
    proto_fields.map { |field| [field, resolve_field(field)] }.to_h
  end

  def resolve_field(field)
    value = try(field) || self[field]

    return value if value.nil?

    if reflection?(field)
      collection?(field) ? value.map(&:to_proto) : value.to_proto
    else
      handle_special_fields(value)
    end
  end

  def reflection?(field)
    self.class.reflections.keys.include?(field)
  end

  def collection?(field)
    self.class.reflect_on_association(field).collection?
  end

  def handle_special_fields(value)
    return value.to_proto if value.respond_to?(:to_proto)
    return value.to_time if value.respond_to?(:strftime)

    value
  end

  def collection_association?(field)
    self.class.reflect_on_association(field).try(:collection?)
  end
end
