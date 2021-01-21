# frozen_string_literal: true

class Points
  def initialize(array_or_hash = [])
    points = Array.wrap(array_or_hash).map(&method(:resolve_point)) || []
    @points = points.select(&:present?)
  end

  def resolve_point(point)
    if point.is_a?(Point)
      point
    else
      t = point.with_indifferent_access
      Point.new(x: t[:x], y: t[:y])
    end
  end

  def push(point)
    @points.push(resolve_point(point))
  end

  def to_proto
    @points.map(&:to_proto)
  end
end
