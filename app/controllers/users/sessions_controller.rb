class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    return render json: { message: 'You are logged in.' }, status: 200 if current_user
    render json: { message: 'wrong credentials entered' }, status: 403
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