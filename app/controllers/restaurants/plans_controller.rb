# frozen_string_literal: true

module Restaurants
  # plan Controller
  class PlansController < ApplicationController
    include Restaurants::ShowPlanData
    include Restaurants::PlanResponse

    load_and_authorize_resource
    before_action :get_plan, except: %i[index create active_users]

    def index
      @plans = Plan.includes(:age_category, days: { meals: %i[meal_category recipe] }).all
      render json: { plans: show_plans }, status: 200
    end

    def show
      render json: { plan: show_plan }, status: 200
    end

    def create
      @plan = Plan.new(plan_params)
      return @plan.errors.messages unless @plan.valid?
      variables_for_plan
      check_for_errors(@plan_cost, @plan_duration, @plan_meals)
      return render json: { message: @errors }, status: 406 if @is_error
      if @plan.save
        add_days(@plan_meals)
        return render json: { message: @errors }, status: 406 if @is_error
        render json: { message: 'plan created', plan: show_plan }, status: 201
      else
        render json: { message: @plan.errors.messages }, status: 406
      end
    end

    def update
      variables_for_plan
      check_for_errors(@plan_cost, @plan_duration, @plan_meals)
      return render json: { message: @errors }, status: 406 if @is_error
      if @plan.update(plan_params)
        update_days(@plan_meals)
        render json: { message: 'plan updated', plan: show_plan }, status: 200
      else
        render json: { message: @plan.errors.messages }, status: 406
      end
    end

    def buy_plan
      ages = @plan.age_category.age.split('-', -1)
      if current_user.age.to_i >= ages[0].to_i and current_user.age.to_i <= ages[1].to_i
        if current_user.active_plan
          send_plan_is_activated_response
        else
          plan_duration = generate_time(Date.today.next_day(@plan.plan_duration))
          user = User.find(current_user.id)
          @expiry_date = Date.today.next_day(@plan.plan_duration)-1
          @activate_plan = ActivePlan.create(user_id: current_user.id, plan_id: @plan.id)
          send_plan_is_purchased_response
        end
      else
        return render json: { message: 'this plan is not suitable for you' }, status: 403
      end
    end

    def change_plan
      plan = Plan.find(params[:id])
      ages = plan.age_category.age.split('-', -1)
      if current_user.age.to_i >= ages[0].to_i and current_user.age.to_i <= ages[1].to_i
        return render json: { message: 'you don\'t have any plan active' }, status: 403 unless current_user.active_plan
        send_plan_is_changed_response(plan)
      else
        return render json: { message: 'this plan is not suitable for you' }, status: 403
      end
    end

    def users_activated
      active_plans = ActivePlan.where(plan_id: @plan.id)
      users = []
      active_plans.each do |active_plan|
        user = User.find(active_plan.user_id)
        users << user
      end
      render json: { users_activated: users }
    end

    def active_users
      users = User.where(active_plan: true)
      render json: { users: users }
    end

    def destroy
      @plan.destroy
      render json: { message: 'plan deleted' }, status: 200
    end

    private

    def plan_params
      params.require(:plan).permit(:name, :description, :plan_duration, :plan_cost, :age_category_id)
    end

    def get_plan
      @plan = Plan.includes(:age_category, days: { meals: %i[meal_category recipe] }).find(params[:id])
    end
  end
end
