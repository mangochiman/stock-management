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
    {:name => "Bado", :price => "3000"},
    {:name => "Water", :price => "300"},
    {:name => "Gualana", :price => "1200"},
    {:name => "Castlite", :price => "1200"},
    {:name => "Heinken", :price => "1200"},
    {:name => "Dragon", :price => "1000"},
    {:name => "Hunters", :price => "1200"},
    {:name => "Amstel", :price => "1200"},
    {:name => "Manica", :price => "800"},
    {:name => "Miller", :price => "1200"},
    {:name => "Green large", :price => "1000"},
    {:name => "Green", :price => "700"},
    {:name => "Special", :price => "700"},
    {:name => "Soft drinks", :price => "400"},
    {:name => "Chill", :price => "900"},
    {:name => "Kuchekuche", :price => "500"},
    {:name => "Ginger", :price => "400"},
    {:name => "Booster", :price => "700"},
    {:name => "Jameson", :price => "1200"},
    {:name => "Amarula", :price => "1000"},
    {:name => "Lime", :price => "300"},
    {:name => "Jack Daniel", :price => "1000"},
    {:name => "Captain Morgan", :price => "1000"},
    {:name => "Brandy", :price => "500"},
    {:name => "Malawi Gin", :price => "400"},
    {:name => "Grants", :price => "1000"},
    {:name => "Overmeer", :price => "1000"},
    {:name => "Black label", :price => "1500"},
    {:name => "NP Brandy", :price => "2500"},
    {:name => "NP Gin", :price => "2000"},
    {:name => "Special large", :price => "1000"},
    {:name => "Lays", :price => "500"},
    {:name => "Nuts", :price => "500"},
    {:name => "Manyuchi", :price => "500"}
]

products.each do |product|
  puts "Creating #{product[:name]}"
  new_product = Product.new
  new_product.name = product[:name]
  new_product.minimum_required = 0
  new_product.starting_inventory = (50..500).to_a.shuffle[6]
  new_product.save

  price_history = PriceHistory.new
  price_history.product_id = new_product.product_id
  price_history.price = product[:price]
  price_history.start_date = "2000-01-01"
  price_history.end_date = "2019-12-31"
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