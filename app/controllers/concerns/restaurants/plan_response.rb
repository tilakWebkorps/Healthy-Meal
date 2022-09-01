module Restaurants
  module PlanResponse
    extend ActiveSupport::Concern

    def send_plan_is_activated_response
      render json: { message: "your plan is already activated try to buy after #{current_user.expiry_date}",
                        plan_expires_on: current_user.expiry_date,
                        plan: plan_url(@plan) }, status: 406
    end

    def send_plan_is_purchased_response
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

    def send_plan_is_changed_response(plan)
      user = User.find(current_user.id)
      active_plan = ActivePlan.includes(:plan).find_by(user_id: current_user.id)
      previous_plan = active_plan.plan
      if active_plan.update(plan_id: params[:id])
        if previous_plan.plan_duration.to_i > plan.plan_duration.to_i
          remain_expiry_days = previous_plan.plan_duration.to_i - plan.plan_duration.to_i
          expiry_date = Date.today+remain_expiry_days-1
          user.update(expiry_date: expiry_date, plan_duration: generate_time(expiry_date+1))
        end
        render json: { message: 'your plan is changed it will continue with your remaining days' }, status: 200
      else
        render json: { message: 'something wrong try again' }, status: 500
      end
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

    def destroy_plan
      @plan.destroy
    end
  end
end