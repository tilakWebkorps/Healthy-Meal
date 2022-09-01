module Restaurants
  module ShowRecipeData
    extend ActiveSupport::Concern
    
    def show_recipes
      recipes = []
      @recipes.each do |recipe|
        recipes << {
          name: recipe.name,
          description: recipe.description,
          ingredients: recipe.ingredients,
          url: recipe_url(recipe)
        }
      end
      recipes
    end

    def show_recipe
      {
        name: @recipe.name,
        description: @recipe.description,
        ingredients: @recipe.ingredients,
        url: recipe_url(@recipe)
      }
    end
  end
end