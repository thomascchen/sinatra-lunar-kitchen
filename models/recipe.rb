require 'pry'
require_relative 'ingredient.rb'

class Recipe
  attr_reader :id, :name, :ingredients, :instructions, :description

  def initialize(id, name, ingredients, instructions, description)
    @id = id
    @name = name
    @ingredients = ingredients
    @instructions = instructions
    @description = description
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.all
    recipes = db_connection do |conn|
      conn.exec("SELECT * FROM recipes")
    end.to_a

    ingredients = db_connection do |conn|
      conn.exec("SELECT name FROM ingredients WHERE recipe_id = $1", [recipes[0]['id']]).to_a
    end

    recipes.map! { |recipe| Recipe.new(recipe["id"], recipe["name"], ingredients, recipe["instructions"], recipe["description"]) }
  end

  def self.find(id)
    recipe = db_connection do |conn|
      conn.exec("SELECT * FROM recipes WHERE id = $1", [id])
    end.to_a

    ingredients = db_connection do |conn|
      conn.exec("SELECT name FROM ingredients WHERE recipe_id = $1", [recipe[0]['id']]).to_a
    end

    ingredients_array = []

    ingredients.each do |ingredient|
      ingredients_array << Ingredient.new(ingredient['name'])
    end

    Recipe.new(recipe[0]["id"].to_i, recipe[0]["name"], ingredients_array, recipe[0]["instructions"], recipe[0]["description"])

  end

end
