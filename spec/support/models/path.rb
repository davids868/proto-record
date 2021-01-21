# frozen_string_literal: true

class Path < ActiveRecord::Base
  attr_reader :name, :description

  has_many :features
end
