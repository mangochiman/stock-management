class Product < ActiveRecord::Base
  self.primary_key = "product_id"

  has_many :price_histories, :foreign_key => :product_id
  default_scope {where ("voided = 0")}

  def self.search_products(q)
    products = Product.where(["name LIKE (?)", "%" + q.to_s + "%"]).order("product_id DESC")
    return products
  end
end
