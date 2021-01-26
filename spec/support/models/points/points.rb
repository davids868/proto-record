# frozen_string_literal: true

class Points
  attr_reader :points

  def initialize(points: [])
    @points = points
  end

  def valid?
    @points.present?
  end

  def push(point)
    @points.push(point)
  end

  def to_proto
    @points.map(&:to_proto)
  end
end
