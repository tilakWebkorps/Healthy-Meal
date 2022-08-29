# frozen_string_literal: true

module Restaurant
  # recipe controller
  class RecipesController < ApplicationController
    load_and_authorize_resource
    before_action :take_recipe, except: %i[index create]
    def index
      @recipes = Recipe.all
      render json: { recipes: @recipes }
    end

    def show
      render json: { recipe: @recipe }
    end

    def create
      @recipe = Recipe.new(recipe_params)
      add_ingredients(params[:recipe][:ingredients])
      if @recipe.save
        render json: { message: 'recipe created', recipe: @recipe }, status: 201
      else
        render json: { message: @recipe.errors.messages }, status: 406
      end
    end

    def update
      if params[:recipe][:ingredients]
        @recipe.ingredients.clear
        add_ingredients(params[:recipe][:ingredients])
      end
      if @recipe.update(recipe_params)
        render json: { message: 'recipe updated', recipe: @recipe }, status: 200
      else
        render json: { message: @recipe.errors.messages }, status: 406
      end
    end

    def destroy
      @recipe.destroy
      render json: { message: 'recipe deleted' }, status: 200
    end

    private

    def recipe_params
      params.require(:recipe).permit(:name, :description)
    end

    def take_recipe
      @recipe = Recipe.find(params[:id])
    end

    def add_ingredients(ingredients)
      ingredients.each do |ingredient|
        @recipe.ingredients << ingredient
      end
    end
  end
end
