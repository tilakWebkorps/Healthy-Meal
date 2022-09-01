module Users
  module ShowUserData
    extend ActiveSupport::Concern

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
        user_details[:plan_expiry] = @user.expiry_date
        user_details[:plan_deatils] = plan_url(@plan)
        user_details[:todays_schedule] = get_schedule
      end
      user_details
    end
  end
end