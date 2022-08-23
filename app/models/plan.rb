class Plan < ApplicationRecord
  has_one_attached :image

  has_many :active_plans
end