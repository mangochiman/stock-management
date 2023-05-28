
require 'csv'

def load_defaults
  products_file = "#{Rails.root}/config/products.csv"
  row_pos = 0
  categories = ["Standard", "Non Standard"]
  categories.each do |category_name|
    category = Category.new
    category.name = category_name
    category.save
  end
  
  CSV.parse(File.open(products_file)).each do |row|
    row_pos += 1
    next if row_pos == 1
    item = row[0]
    price = row[1]
    #quantity = row[2]
    category = row[3]

    puts "Creating #{item}"
    new_product = Product.new
    new_product.name = item
    new_product.minimum_required = 0
    new_product.starting_inventory = 0
    new_product.save

    category = Category.find_by_name(category)
    product_category = ProductCategory.new
    product_category.category_id = category.category_id
    product_category.product_id = new_product.product_id
    product_category.save

    price_history = PriceHistory.new
    price_history.product_id = new_product.product_id
    price_history.price = price
    price_history.start_date = "2000-01-01"
    price_history.save

  end
end
load_defaults

def add_user
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
end
load_defaults
