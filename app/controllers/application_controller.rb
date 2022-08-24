class ApplicationController < ActionController::API
  def return_error(message)
    return render json: { message: message }, status: 406
  end
end
