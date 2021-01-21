# frozen_string_literal: true

class Point
  attr_reader :x, :y

  def initialize(x: nil, y: nil)
    @x = x
    @y = y
  end

  def valid?
    @x.present? && @x.present?
  end

  def to_h
    {
      x: @x,
      y: @y
    }
  end
end
