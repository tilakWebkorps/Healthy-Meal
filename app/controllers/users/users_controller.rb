class Users::UsersController < ApplicationController
  before_action :get_user_data, except: %i[index]
  def index # route -> get /users
    @users = User.all
    render json: { users: @users }, status: 200
  end

  def show # route -> get /users/:id
    render json: { user: @user }, status: 200
  end

  def update # route -> patch /users/:id
    if @user.update(user_params)
      render json: { message: 'User updated succesfully', user: @user }, status: 200
    else
      render json: { message: @user.errors.messages }, status: 406
    end
  end

  def destroy # route -> delete /users/:id
    @user.destroy
    render json: { message: 'User deleted successfully' }, status: 200
  end

  private

  def get_user_data # for before action filter
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :age, :weight)
  end
end