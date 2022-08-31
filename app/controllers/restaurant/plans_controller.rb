# frozen_string_literal: true

module Restaurant
  # plan Controller
  class PlansController < ApplicationController
    load_and_authorize_resource except: [:buy_plan]
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
          render json: { message: "your plan is already activated try to buy after #{current_user.expiry_date}",
                        plan_expires_on: current_user.expiry_date,
                        plan: plan_url(@plan) }, status: 406
        else
          plan_duration = generate_time(Date.today.next_day(@plan.plan_duration))
          user = User.find(current_user.id)
          @expiry_date = Date.today.next_day(@plan.plan_duration)-1
          @activate_plan = ActivePlan.create(user_id: current_user.id, plan_id: @plan.id)
          if @activate_plan.save
            if user.update(active_plan: true, plan_duration: plan_duration.to_i, expiry_date: @expiry_date)
              UserMailer.plan_purchased(current_user).deliver_later
              render json: { message: 'purchase successfull', bill: generate_bill }, status: 200
            else
              render json: { message: 'something wrong' }, status: 500
            end
          else
            render json: { message: 'something wrong try again' }, status: 500
          end
        end
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

    def variables_for_plan
      @plan_cost = params[:plan][:plan_cost].to_i
      @plan_duration = params[:plan][:plan_duration].to_i
      @plan_meals = params[:plan][:plan_meals]
      @errors = {}
      @is_error = false
    end

    def check_for_errors(cost, duration, meals)
      if cost < 1000
        @is_error = true
        @errors[:plan_cost] = 'cost of the plan must be larger than 1000'
      end
      unless [7, 14, 21].include? duration
        @is_error = true
        @errors[:plan_duration] = 'duration must be 7, 14 or 21'
      end
      unless duration == meals.size
        @is_error = true
        @errors[:plan_meals] = 'please enter all day\'s schedules'
      end
      @is_error
    end

    def add_days(day_meals)
      for_day = 1
      day_meals.each do |day|
        @day = Day.new(for_day: for_day.to_i, plan_id: @plan.id)
        if @day.save
          add_meal(day)
          for_day += 1
        end
      end
    end

    def add_meal(meals)
      category = 1
      recipes = Recipe.all.ids
      meals.each do |meal, recipe|
        if %w[morning_snacks lunch afternoon_snacks dinner hydration].include? meal
          if recipes.include? recipe
            @meal = Meal.new(day_id: @day.id, meal_category_id: category, recipe_id: recipe.to_i)
            @meal.save
            category += 1
          else
            @is_error = true
            destroy_plan
            @errors[:recipe] = 'the recipe that you give is not found first create it'
          end
        else
          @is_error = true
          destroy_plan
          @errors[:meal] = 'please enter all meal schedule corretly'
        end
      end
    end

    def update_days(plan_meals)
      for_day = 0
      days = @plan.days.sort
      days.each do |day|
        plan_meal = plan_meals[for_day]
        update_meals(day.meals, plan_meal)
        for_day += 1
      end
    end

    def update_meals(meals, plan_meals)
      for_meal = 0
      plan_meals.each do |_plan_meal, recipe|
        meal = meals[for_meal]
        meal.recipe_id = recipe.to_i
        meal.save
        for_meal += 1
      end
    end

    def show_plan
      ages = @plan.age_category.age.split('-', -1)
      return plan = {} unless current_user.age.to_i >= ages[0].to_i and current_user.age <= ages[1].to_i
      plan = create_plan(@plan)
      plan[:plan_meal] = show_plan_day
      plan
    end

    def show_plan_day
      plan_meals = []
      @plan.days.each do |day|
        plan_meal = {}
        plan_meal[:day] = day.for_day
        day.meals.each do |meal|
          plan_meal[meal.meal_category.name] = give_recipe(meal.recipe)
        end
        plan_meals << plan_meal
      end
      plan_meals
    end

    def show_plans
      plans = []
      @plans.each do |plan|
        ages = plan.age_category.age.split('-', -1)
        if current_user.role == 'admin'
          plans << create_plan(plan)
        elsif current_user.age.to_i >= ages[0].to_i and current_user.age <= ages[1].to_i
          plans << create_plan(plan)
        end
      end
      plans
    end

    def create_plan(plan)
      {
        id: plan.id,
        name: plan.name,
        description: plan.description,
        for_age: plan.age_category.age,
        plan_duration: plan.plan_duration,
        plan_cost: plan.plan_cost,
        view_url: plan_url(plan),
        buy_url: buy_plan_url(plan)
      }
    end

    def generate_bill
      {
        plan_name: @plan.name,
        plan_description: @plan.description,
        plan_cost: @plan.plan_cost,
        plan_duration: @plan.plan_duration,
        expiry_date: @expiry_date
      }
    end

    def destroy_plan
      @plan.destroy
    end
  end
end
