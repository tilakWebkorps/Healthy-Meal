# frozen_string_literal: true

module Users
  # user controller
  class UsersController < ApplicationController
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

    private

    def take_user_data
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :age, :weight, :role)
    end

    def show_user
      user_details = {
        name: @user.name,
        email: @user.email,
        age: @user.age,
        weight: @user.weight,
        plan_activated: @user.active_plan
      }
      if @user.active_plan
        active_plan = ActivePlan.includes(plan: { days: { meals: %i[meal_category recipe] } }).find_by(user_id: @user.id)
        @plan = active_plan.plan
        user_details[:plan_expiry] = "#{@user.expiry_date.day}/#{@user.expiry_date.month}/#{@user.expiry_date.year}"
        user_details[:plan_deatils] = plan_url(@plan)
        user_details[:todays_schedule] = get_schedule
      end
      user_details
    end

    def get_schedule
      schedule = {}
      expiry_date = @user.expiry_date
      today_date = Date.today
      remain_days = (today_date...expiry_date).count
      schedule_for = @plan.plan_duration-remain_days
      @plan.days.each do |day|
        if schedule_for.to_i == day.for_day.to_i
          schedule[:day] = day.for_day.to_i
          day.meals.each do |meal|
            schedule[meal.meal_category.name] = give_recipe(meal.recipe)
          end
        end
      end
      schedule
    end
  end
end
