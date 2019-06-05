# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
#
products = [
    {:name => "Bado", :price => "3000", :category => "Standard"},
    {:name => "Water", :price => "300", :category => "Standard"},
    {:name => "Gualana", :price => "1200", :category => "Standard"},
    {:name => "Castlite", :price => "1200", :category => "Standard"},
    {:name => "Heinken", :price => "1200", :category => "Standard"},
    {:name => "Dragon", :price => "1000", :category => "Standard"},
    {:name => "Hunters", :price => "1200", :category => "Standard"},
    {:name => "Amstel", :price => "1200", :category => "Standard"},
    {:name => "Manica", :price => "800", :category => "Standard"},
    {:name => "Miller", :price => "1200", :category => "Standard"},
    {:name => "Green large", :price => "1000", :category => "Standard"},
    {:name => "Green", :price => "700", :category => "Standard"},
    {:name => "Special", :price => "700", :category => "Standard"},
    {:name => "Soft drinks", :price => "400", :category => "Standard"},
    {:name => "Chill", :price => "900", :category => "Standard"},
    {:name => "Kuchekuche", :price => "500", :category => "Standard"},
    {:name => "Ginger", :price => "400", :category => "Standard"},
    {:name => "Booster", :price => "700", :category => "Standard"},
    {:name => "Jameson", :price => "1200", :category => "Non standard"},
    {:name => "Amarula", :price => "1000", :category => "Non standard"},
    {:name => "Lime", :price => "300", :category => "Non standard"},
    {:name => "Jack Daniel", :price => "1000", :category => "Non standard"},
    {:name => "Captain Morgan", :price => "1000", :category => "Non standard"},
    {:name => "Brandy", :price => "500", :category => "Non standard"},
    {:name => "Malawi Gin", :price => "400", :category => "Non standard"},
    {:name => "Grants", :price => "1000", :category => "Non standard"},
    {:name => "Overmeer", :price => "1000", :category => "Non standard"},
    {:name => "Black label", :price => "1500", :category => "Non Standard"},
    {:name => "NP Brandy", :price => "2500", :category => "Standard"},
    {:name => "NP Gin", :price => "2000", :category => "Standard"},
    {:name => "Special large", :price => "1000", :category => "Standard"},
    {:name => "Lays", :price => "500", :category => "Standard"},
    {:name => "Nuts", :price => "500", :category => "Standard"},
    {:name => "Manyuchi", :price => "500", :category => "Standard"}
]

categories = ["Standard", "Non Standard"]
categories.each do |category_name|
  category = Category.new
  category.name = category_name
  category.save
end

products.each do |product|
  puts "Creating #{product[:name]}"
  new_product = Product.new
  new_product.name = product[:name]
  new_product.minimum_required = 0
  new_product.starting_inventory = (50..500).to_a.shuffle[6]
  new_product.save

  category = Category.find_by_name(product[:category])
  product_category = ProductCategory.new
  product_category.category_id = category.category_id
  product_category.product_id = new_product.product_id
  product_category.save

  price_history = PriceHistory.new
  price_history.product_id = new_product.product_id
  price_history.price = product[:price]
  price_history.start_date = "2000-01-01"
  price_history.save

end

salt = User.random_string(10)
user = User.new
user.first_name = "John"
user.last_name = "Banda"
user.email = "j@gmail.com"
user.phone_number = "01000000"
user.password = User.encrypt("test", salt)
user.salt = salt
user.username = "admin"
user.save

user_role = UserRole.new
user_role.user_id = user.user_id
user_role.role = "Admin"
user_role.save