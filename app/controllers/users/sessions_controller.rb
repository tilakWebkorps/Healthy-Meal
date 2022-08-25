class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    begin
      Exception.handle(current_user)
      if current_user
        check_user_plan_expiry
        return render json: { message: 'You are logged in.' }, status: 200
      end
      render json: { message: 'wrong credentials entered' }, status: 403
    rescue StandardError => e
      render json: { message: e.message }
    end
  end

  def respond_to_on_destroy
    log_out_success && return if current_user

    log_out_failure
  end

  def log_out_success
    render json: { message: "You are logged out." }, status: 200
  end

  def log_out_failure
    render json: { message: "Hmm nothing happened."}, status: 401
  end
end