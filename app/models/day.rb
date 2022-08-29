# frozen_string_literal: true

class Day < ApplicationRecord
  belongs_to :plan
  has_many :meals, dependent: :destroy
end
