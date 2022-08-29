# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :jwt_authenticatable, :registerable, jwt_revocation_strategy: JwtDenylist

  email_regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  validates :name, presence: true, length: { minimum: 3 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 7 }, format: { with: email_regex, message: 'email format is invalid' }
  validates :age, presence: true
  validates :weight, presence: true
end
