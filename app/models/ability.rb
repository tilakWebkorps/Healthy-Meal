# frozen_string_literal: true

# cancancan
class Ability
  include CanCan::Ability

  def initialize(user)
    can %i[read], Plan
    return unless user.present?

    can %i[show update destroy], User, id: user.id
    return unless user.role == 'admin'

    can :manage, :all
  end
end
