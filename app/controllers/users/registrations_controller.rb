class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  respond_to :json

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :age, :weight])
  end

  def respond_with(resource, _opts = {})
    register_success && return if resource.persisted?

    register_failed
  end

  def register_success
    UserMailer.user_welcome(current_user).deliver_later
    render json: { message: 'Signed up sucessfully.' }, status: 201
  end

  def register_failed
    render json: { message: resource.errors.messages }, status: 406 if resource
  end
end