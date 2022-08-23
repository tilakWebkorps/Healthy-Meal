class Day < ApplicationRecord
  belongs_to :plan
  has_many :meals, dependent: :destroy
end
