class PointType < ActiveRecord::Type::Value
  def type
    :json
  end

  def cast(value)
    Point.new(**value) if value
  end

  def deserialize(value)
    if value.is_a?(String)
      decoded = ::ActiveSupport::JSON.decode(value) rescue nil
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
