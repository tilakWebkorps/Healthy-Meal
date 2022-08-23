class Plan < ApplicationRecord
  has_one_attached :image

  has_many :active_plans
  has_many :days, dependent: :destroy

  validates :name, presence: true
  validates :plan_duration, presence: true, numericality: { only_integer: true }, inclusion: [7,14,21]
  validates :plan_cost, presence: true, numericality: { only_integer: true }
end