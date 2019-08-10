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

  def render_products
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

  def render_standard_products_data
    date = params[:date].to_date
    standard_products = Product.standard_items.order("name ASC")
    helper = ActionController::Base.helpers
    data = []
    stock_id = Stock.where(["DATE(stock_time) = ?", date.to_date]).order("stock_id DESC").first.stock_id rescue nil
    standard_products.each do |product|
      current_stock = product.current_stock(date)
      added_stock = product.added_stock_by_date(date)
      closing_stock = product.closed_stock_by_date(date)
      opening_stock =  product.opening_stock_by_date(date)
      price = product.price(date)
      damaged_stock = product.damaged_stock(stock_id)
      complementary_stock = product.complementary_stock(stock_id)

      data << {
          product_id: product.product_id,
          product_name: product.name,
          opening: opening_stock.to_s,
          add: added_stock.to_s,
          product_price: helper.number_to_currency(price, :unit => "MWK "),
          closing_stock: closing_stock.to_s,
          damaged_stock: damaged_stock.to_s,
          complementary_stock: complementary_stock.to_s,
          difference: ((current_stock.to_i + added_stock.to_i) - closing_stock.to_i).to_s,
          current_stock: current_stock.to_s
      }

    end

    render json: data.to_json
  end

  def search_debtors
    debtors = Debtor.unpaid_debts_records
    data = []
    debtors.each do |debtor|
      if debtor.name.match(/#{params[:name]}/i)
        data << {
            name: debtor.name,
            amount_owed: debtor.amount_owed,
            phone_number: debtor.phone_number.to_s,
            amount_paid: debtor.amount_paid,
            date: debtor.date,
            balance_due: debtor.balance_due
        }
      end
    end
    render json: data.to_json
  end

  def overdue_debtors
    debtors = Debtor.overdue_debtors
    data = []
    debtors.each do |debtor|
      data << {
          name: debtor.name,
          amount_owed: debtor.amount_owed,
          phone_number: debtor.phone_number.to_s,
          amount_paid: debtor.amount_paid,
          date: debtor.date,
          days_gone: (Date.today - debtor.date.to_date).to_i,
          balance_due: debtor.balance_due
      }
    end
    render json: data.to_json
  end

  def search_overdue_debtors
    debtors = Debtor.overdue_debtors
    data = []
    debtors.each do |debtor|
      if debtor.name.match(/#{params[:name]}/i)
        data << {
            name: debtor.name,
            amount_owed: debtor.amount_owed,
            phone_number: debtor.phone_number.to_s,
            amount_paid: debtor.amount_paid,
            date: debtor.date,
            days_gone: (Date.today - debtor.date.to_date).to_i,
            balance_due: debtor.balance_due
        }
      end
    end
    render json: data.to_json
  end

  def render_debtor_payments
    debtor_payments = DebtorPayment.order("debtor_payment_id DESC")
    data = []
    helper = ActionController::Base.helpers
    debtor_payments.each do |debtor_payment|
      data << {
          debtor: debtor_payment.debtor.name,
          amount_paid: helper.number_to_currency(debtor_payment.amount_paid, :unit => "MWK "),
          amount_owed: helper.number_to_currency(debtor_payment.debtor.amount_owed, :unit => "MWK "),
          date_paid: (debtor_payment.date_paid.strftime("%d-%b-%Y") rescue debtor_payment.date_paid),
          date_owed: (debtor_payment.debtor.date.strftime("%d-%b-%Y") rescue debtor_payment.debtor.date),
      }
    end
    render json: data.to_json
  end

  def search_debtor_payments
    debtor_payments = DebtorPayment.order("debtor_payment_id DESC")
    data = []
    helper = ActionController::Base.helpers
    debtor_payments.each do |debtor_payment|
      if debtor_payment.debtor.name.match(/#{params[:name]}/i)
        data << {
            debtor: debtor_payment.debtor.name,
            amount_paid: helper.number_to_currency(debtor_payment.amount_paid, :unit => "MWK "),
            amount_owed: helper.number_to_currency(debtor_payment.debtor.amount_owed, :unit => "MWK "),
            date_paid: (debtor_payment.date_paid.strftime("%d-%b-%Y") rescue debtor_payment.date_paid),
            date_owed: (debtor_payment.debtor.date.strftime("%d-%b-%Y") rescue debtor_payment.debtor.date),
        }
      end
    end
    render json: data.to_json
  end

  def create_product
    product = Product.new
    product.name = params[:name]
    product.label = params[:label]
    product.part_number = params[:part_number]
    product.starting_inventory = params[:starting_inventory]
    product.minimum_required = params[:minimum_required]

    category_id = Category.find_by_name(params[:category]).category_id rescue Category.first.category_id
    if product.save
      product_category = ProductCategory.new
      product_category.category_id = category_id
      product_category.product_id = product.product_id
      product_category.save
      data = {
          product_id: product.product_id.to_s,
          name: product.name,
          label: product.label,
          part_number: product.part_number,
          starting_inventory: product.starting_inventory.to_s,
          minimum_required: product.minimum_required.to_s
      }
      render json: data.to_json and return
    else
      data = {}
      errors = product.errors.full_messages
      data["errors"] = errors
      render json: data.to_json and return
    end

  end

  def create_product_prices
    product = Product.find(params[:product_id])
    data = {}
    price_history = PriceHistory.new
    price_history.product_id = product.product_id
    price_history.price = params[:price]
    price_history.start_date = params[:start_date]
    product_price_histories = product.price_histories.order("DATE(start_date) DESC")
    start_date_collides = false
    new_start_date = params[:start_date].to_date
    product_price_histories.each do |old_price_history|
      start_date = old_price_history.start_date.to_date
      end_date = old_price_history.end_date.to_date rescue start_date
      if end_date >= new_start_date
        start_date_collides = true
        break
      end
    end

    if start_date_collides
      errors = ["The new start date is colliding with previous dates of another price of the same product"]
      data["errors"] = errors
      render json: data.to_json and return
    end

    PriceHistory.set_price_end_dates(params[:product_id], (params[:start_date].to_date - 1.day))
    if price_history.save
      data = {
          product_id: product.product_id,
          price: price_history.price.to_s,
          start_date: price_history.start_date
      }
      render json: data.to_json and return
    else
      errors = price_history.errors.full_messages
      data["errors"] = errors
      render json: data.to_json and return
    end

  end

  def reports
    date = params[:date].to_date
    helper = ActionController::Base.helpers
    stock_stats_by_date = Product.stock_stats_by_date(date)
    total_debts = Debtor.total_debts_by_date(date)
    stock_id = Stock.where(["DATE(stock_time) = ?", date]).order("stock_id DESC").first.stock_id rescue nil
    cash_collected = Stock.find(stock_id).amount_collected.to_f rescue "0"

    data = {}
    data["complementary_total"] = helper.number_to_currency(stock_stats_by_date["complementary_total"], :unit => "MWK ")
    data["damages_total"] = helper.number_to_currency(stock_stats_by_date["damages_total"], :unit => "MWK ")
    data["total_sales"] = helper.number_to_currency(stock_stats_by_date["total_sales"], :unit => "MWK ")
    data["debtors"] = helper.number_to_currency(total_debts, :unit => "MWK ")
    data["expected_cash"] = helper.number_to_currency((stock_stats_by_date["total_sales"] - total_debts), :unit => "MWK ")
    data["collected_cash"] = helper.number_to_currency(cash_collected, :unit => "MWK ")
    data["shortages"] = helper.number_to_currency((stock_stats_by_date["total_sales"] - total_debts) - cash_collected.to_i, :unit => "MWK ")
    render json: data.to_json and return
  end

  def render_debt_payment_period
    debt_payment_period = Setting.find_by_property("debt.payment.period").value rescue ""
    data = {days: debt_payment_period}
    render json: data.to_json and return
  end

  def update_settings
    setting = Setting.find_by_property(params[:property])
    if setting.blank?
      setting = Setting.new
      setting.property = params[:property]
    end
    setting.value = params[:value].to_i
    setting.save

    render json: setting.to_json
  end

  def add_stock
    date = params[:stock_date].to_date
    product_addition = ProductAddition.new
    product_addition.added_stock = params[:quantity]
    product_addition.product_id = params[:product_id]
    product_addition.date_added = date
    product = Product.find(params[:product_id])

    if product_addition.save
      current_stock = product.current_stock(date)
      added_stock = product.added_stock_by_date(date)

      data = {
          product_id: product_addition.product_id.to_s,
          added_stock: added_stock.to_s,
          date_added: product_addition.date_added.to_s,
          current_stock: current_stock.to_s
      }

      render json: data.to_json and return
    else
      data = {}
      errors = product_addition.errors.full_messages
      data["errors"] = errors
      render json: data.to_json and return
    end

  end

end
