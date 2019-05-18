class Category < ActiveRecord::Base
  self.table_name = "categories"
  self.primary_key = "category_id"
end
