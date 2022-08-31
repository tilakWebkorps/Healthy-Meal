# frozen_string_literal: true

module Users
  # session controller
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(_resource, _opts = {})
      if current_user
        check_user_plan_expiry
        return render json: { message: 'You are logged in.' }, status: 200
      end
      render json: { message: 'wrong credentials entered' }, status: 403
    end

    def respond_to_on_destroy
      log_out_success && return if current_user

      log_out_failure
    end

    def log_out_success
      render json: { message: 'You are logged out.' }, status: 200
    end

    def log_out_failure
      render json: { message: 'You are not logged in..' }, status: 401
    end
  end
end
