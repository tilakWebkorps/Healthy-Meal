# frozen_string_literal: true

module Users
  # user controller
  class UsersController < ApplicationController
    include Users::ShowUserData
    
    load_and_authorize_resource
    before_action :take_user_data, except: %i[index]
    def index
      @users = User.all
      render json: { users: @users }, status: 200
    end

    def show
      check_user_plan_expiry
      render json: { user: show_user }, status: 200
    end

    def update
      if @user.update(user_params)
        render json: { message: 'User updated succesfully', user: @user, view_url: users_user_url(@user) }, status: 200
      else
        render json: { message: @user.errors.messages }, status: 406
      end
    end

    def destroy
      if @user.active_plan
        active_plan = ActivePlan.find_by(user_id: @user.id)
        active_plan.destroy
      end
      @user.destroy
      render json: { message: 'User deleted successfully' }, status: 200
    end

    def set_role
      if @user.update(role: params[:user][:role])
        render json: { message: "role seted #{params[:user][:role]}" }
      else
        render json: { message: 'something wrong try again' }, status: 500
      end
    end

    private

    def take_user_data
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :age, :weight)
    end
  end
end
