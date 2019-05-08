class Product < ActiveRecord::Base
  self.primary_key = "product_id"

  default_scope {where ("voided = 0")}


end
