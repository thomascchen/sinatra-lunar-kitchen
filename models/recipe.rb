require_relative 'ingredient.rb'

class Recipe
  attr_reader :id, :name, :instructions, :description

  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @ingredients = ingredients
    @instructions = instructions
    @description = description
  end

  def db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  def ingredients
    ingredients = db_connection do |conn|
      conn.exec("SELECT name FROM ingredients WHERE recipe_id = $1", [id])
    end

    ingredients_array = []

    ingredients.each do |ingredient|
      ingredients_array << Ingredient.new(ingredient['name'])
    end

    ingredients_array
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

    recipes.map! { |recipe| Recipe.new(recipe["id"], recipe["name"], recipe["instructions"], recipe["description"]) }
  end

  def self.find(id)
    recipe = db_connection do |conn|
      conn.exec("SELECT * FROM recipes WHERE id = $1", [id])
    end.to_a

    Recipe.new(recipe[0]["id"].to_i, recipe[0]["name"], recipe[0]["instructions"], recipe[0]["description"])

  end

end
