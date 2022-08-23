class Restaurant::PlansController < ApplicationController
  before_action :get_plan, except: %i[index create]
  def index
    @plans = Plan.all
    render json: { plans: @plans }, status: 200
  end

  def show
    render json: { plan: @plan }, status: 200
  end

  def create
    @plan = Plan.new(plan_params)
    plan_cost = params[:plan][:plan_cost].to_i
    plan_duration = params[:plan][:plan_duration].to_i
    plan_meals = params[:plan][:plan_meals]
    @errors = {}
    is_error = check_for_errors(plan_cost, plan_duration, plan_meals)
    return render json: { message: @errors }, status: 406 if is_error
    if @plan.save
      add_days(plan_meals)
      render json: { message: 'plan created', plan: @plan }, status: 201
    else
      render json: { message: @plan.errors.messages }, status: 406
    end
  end

  def update
    if @plan.update(plan_params)
      render json: { message: 'plan updated', plan: @plan }, status: 200
    else
      render json: { message: @plan.errors.messages }, status: 406
    end
  end

  def destroy
    @plan.destroy
    render json: { message: 'plan deleted' }, status: 200
  end

  private

  def plan_params
    params.require(:plan).permit(:name, :description, :plan_duration, :plan_cost, :image)
  end

  def get_plan
    @plan = Plan.find(params[:id])
  end

  def check_for_errors(cost, duration, meals)
    is_error = false
    if cost < 1000
      is_error = true
      @errors[:plan_cost] = 'cost of the plan must be larger than 1000'
    end
    unless [7,14,21].include? duration
      is_error = true
      @errors[:plan_duration] = 'duration must be 7, 14 or 21'
    end
    unless duration == meals.size
      is_error = true
      @errors[:plan_meals] = 'please enter all day\'s schedules'
    end
    return is_error
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
    meals.each do |meal, recipe|
      @meal = Meal.new(day_id: @day.id, meal_category_id: category, recipe_id: recipe.to_i)
      @meal.save
      category += 1
    end
  end
end