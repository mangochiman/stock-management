class ApiController < ApplicationController

  def render_debtors
    debtors = Debtor.unpaid_debts_records
    data = []
    debtors.each do |debtor|
      data << {
          name: debtor.name,
          amount_owed: debtor.amount_owed,
          phone_number: debtor.phone_number.to_s,
          amount_paid: debtor.amount_paid,
          date: debtor.date,
          balance_due: debtor.balance_due
      }
    end
    render json: data.to_json
  end

  def render_damages
    stock_items = StockItem.where(["damaged_stock IS NOT NULL"])
    data = []

    stock_items.each do |stock_item|
      stock_date = stock_item.stock.stock_time.to_date
      damaged_stock = stock_item.damaged_stock
      product_price = stock_item.product.price(stock_date)
      total_damages = damaged_stock.to_f * product_price.to_f
      product_name = stock_item.product.name
      product_category = stock_item.product.category_name

      data << {
          product_name: product_name,
          product_category: product_category,
          stock_date: stock_date,
          damaged_quantity: damaged_stock,
          product_price: product_price,
          damaged_value: total_damages
      }

    end

    render json: data.to_json
  end

  def render_complementary
    stock_items = StockItem.where(["complementary_stock IS NOT NULL"])
    data = []

    stock_items.each do |stock_item|
      stock_date = stock_item.stock.stock_time.to_date
      complementary_stock = stock_item.complementary_stock
      product_price = stock_item.product.price(stock_date)
      total_complementary = complementary_stock.to_f * product_price.to_f
      product_name = stock_item.product.name
      product_category = stock_item.product.category_name

      data << {
          product_name: product_name,
          product_category: product_category,
          stock_date: stock_date,
          complementary_quantity: complementary_stock,
          product_price: product_price,
          complementary_value: total_complementary
      }

    end

    render json: data.to_json
  end

  def render_user_accounts
    users = User.all
    data = []

    users.each do |user|
      data << {
          username: user.username,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          phone_number: user.phone_number,
          role: user.role
      }

    end

    render json: data.to_json
  end

  def render_products_running_out_of_stock
    products = Product.running_out_of_stock
    data = []
    products.each do |product|
      data << {
          product_name: product.name,
          product_category: product.category_name,
          minimum_required: product.minimum_required,
          current_stock: product.current_stock
      }
    end

    render json: data.to_json
  end

  def render_products_out_of_stock
    products = Product.products_not_in_stock
    data = []
    products.each do |product|
      data << {
          product_name: product.name,
          product_category: product.category_name,
          minimum_required: product.minimum_required,
          current_stock: product.current_stock
      }
    end

    render json: data.to_json
  end

  def render_products_prices
    products = Product.order("name ASC")
    data = []
    products.each do |product|
      data << {
          product_id: product.product_id,
          product_price: product.price,
          product_name: product.name,
          product_category: product.category_name
      }
    end

    render json: data.to_json
  end

  def render_price_history
    product = Product.find(params[:product_id])
    price_histories = product.price_histories.order("price_history_id DESC")
    data = []
    helper = ActionController::Base.helpers
    price_histories.each do |price_history|
      price = helper.number_to_currency(price_history.price, :unit => "MWK ")
      start_date = price_history.start_date.to_date.strftime("%d-%b-%Y") rescue price_history.start_date
      end_date = price_history.end_date.to_date.strftime("%d-%b-%Y") rescue price_history.end_date.to_s
      created_at = price_history.created_at.to_date.strftime("%d-%b-%Y") rescue price_history.created_at
      data << {
          price: price,
          start_date: start_date,
          end_date: end_date,
          created_at: created_at
      }
    end

    render json: data.to_json
  end

  def render_productss
    products = Product.order("name ASC")
    data = []
    products.each do |product|
      data << {
          product_id: product.product_id,
          product_price: product.price,
          product_name: product.name,
          product_category: product.category_name,
          minimum_required: product.minimum_required,
          starting_stock: product.starting_inventory,
          current_stock: product.current_stock
      }
    end

    render json: data.to_json
  end

end
