# frozen_string_literal: true

module ProtoRecord
  class MissingProtoMessage < StandardError
    def initialize(class_name)
      super("'proto_message' hasn't been defined for #{class_name}.")
    end
  end

  class MissingFieldsResolver < StandardError
    def initialize(class_name)
      super("'fields_resolver' hasn't been defined for #{class_name}.")
    end
  end
end
