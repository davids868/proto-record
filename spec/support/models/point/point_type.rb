# frozen_string_literal: true

class PointType < ActiveRecord::Type::Value
  def type
    :json
  end

  def cast(value)
    Point.new(**value) if value
  end

  def deserialize(value)
    if value.is_a?(String)
      decoded = begin
                  ::ActiveSupport::JSON.decode(value)
                rescue StandardError
                  nil
                end
      Point.new(x: decoded["x"], y: decoded["y"]) if decoded
    else
      super
    end
  end

  def serialize(value)
    case value
    when Hash, Point
      ::ActiveSupport::JSON.encode(value)
    else
      super
    end
  end
end
