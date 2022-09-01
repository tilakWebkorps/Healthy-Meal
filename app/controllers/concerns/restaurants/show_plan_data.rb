module Restaurants
  module ShowPlanData
    extend ActiveSupport::Concern

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

    def show_plan
      plan = create_plan(@plan)
      plan[:plan_meal] = show_plan_day
      ages = @plan.age_category.age.split('-', -1)
      return plan if current_user.role == 'admin'

      return plan = {} if current_user.age.to_i >= ages[0].to_i and current_user.age <= ages[1].to_i
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
  end
end