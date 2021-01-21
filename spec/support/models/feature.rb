# frozen_string_literal: true

class Feature < ActiveRecord::Base
  attr_reader :name

  belongs_to :path
  attribute :point, PointType.new
  attribute :points
end
