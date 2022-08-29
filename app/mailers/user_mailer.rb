# frozen_string_literal: true

# mailling
class UserMailer < ApplicationMailer
  def user_welcome(user)
    @user = user
    @sign_in = user_session_url
    @plans = plans_url
    mail(to: @user.email, subject: 'Welcome')
  end

  def plan_purchased(user)
    @user = user
    active_plan = ActivePlan.includes(:plan).find_by(user_id: user.id)
    @plan = active_plan.plan
    mail(to: @user.email, subject: 'Plan Purchased')
  end

  def plan_expires(user)
    @user = user
    mail(to: @user.email, subject: 'Plan Expired')
  end
end
