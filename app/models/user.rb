class User < ApplicationRecord
  devise :database_authenticatable,
    :jwt_authenticatable,
    :registerable,
    jwt_revocation_strategy: JwtDenylist

  validates :name, presence: true, length: { minimum: 3 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 7 }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, message: "email format is invalid" }
  validates :age, presence: true
  validates :weight, presence: true
end
