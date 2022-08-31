# frozen_string_literal: true

class Plan < ApplicationRecord
  has_many :active_plans
  has_many :days, dependent: :destroy
  belongs_to :age_category

  validates :name, presence: true
  validates :plan_duration, presence: true, numericality: { only_integer: true }, inclusion: [7, 14, 21]
  validates :plan_cost, presence: true, numericality: { only_integer: true }
  validates :age_category_id, presence: true, numericality: { only_integer: true }
end
