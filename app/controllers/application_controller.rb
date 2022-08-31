# frozen_string_literal: true

# Application Controller
class ApplicationController < ActionController::API
  rescue_from CanCan::AccessDenied do
    render json: { message: 'This User Not Authorised !', sign_in_url: user_session_url }, status: 401
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { message: 'record not found' }, status: 404
  end

  def check_user_plan_expiry
    return unless current_user.active_plan
    time = generate_time(Date.today)
    return unless time.to_i >= current_user.plan_duration

    active_plan = ActivePlan.find_by(user_id: current_user.id)
    return unless active_plan.destroy
    set_user_plan
  end

  def set_user_plan
    user = User.find(current_user.id)
    UserMailer.plan_expires(user).deliver_later
    user.active_plan = false
    user.plan_duration = 0
    user.expiry_date = nil
    user.save
  end

  def generate_time(time)
    date = ''
    date += time.year.to_s
    date += '0' if time.month.to_i < 10
    date += time.month.to_s
    date += '0' if time.day.to_i < 10
    date += time.day.to_s
    date
  end

  def give_recipe(recipe)
    {
      name: recipe.name,
      description: recipe.description,
      ingredients: recipe.ingredients,
      url: recipe_url(recipe)
    }
  end

  # exception creation and handler
  class Exception < StandardError
    # if user not logged in send exception
    class UserNotLoggedIn < StandardError
      def message
        'User is not logged in'
      end
    end

    def self.handle(current_user)
      raise UserNotLoggedIn unless current_user
    end
  end

  def routing_error
    render json: { message: 'Route not found' }, status: 404
  end
end
