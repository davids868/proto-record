# frozen_string_literal: true

class PointsType < ActiveRecord::Type::Value
  def type
    :json
  end

  def cast(value)
    Points.new(**value) if value
  end

  def deserialize(value)
    if value.is_a?(String)
      decoded = begin
        ::ActiveSupport::JSON.decode(value)
      rescue StandardError
        nil
      end
      Points.new(points: decoded["points"].map { |p| Point.new(p.symbolize_keys) })
    else
      super
    end
  end

  def serialize(value)
    case value
    when Array, Hash, Points
      ::ActiveSupport::JSON.encode(value)
    else
      super
    end
  end
end
