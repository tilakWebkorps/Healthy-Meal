# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can %i[read], Plan
    return unless user.present?
    can %i[show update destroy], User, user: user
    return unless user.role == 'admin'
    can :manage, :all
  end
end
