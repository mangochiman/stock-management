class HomeController < ApplicationController
  before_filter :authorize

  def home
    @page_header = "Dashboard"


    start_day_date = Date.today
    #end_day_date = Date.today

    day_name = start_day_date.strftime("%A")
    start_week_date = Date.today.beginning_of_week - 1.day #sunday
    if day_name.match(/Sunday/i)
      start_week_date = Date.today
    end
    end_week_date = start_week_date + 6.days #saturday
    start_month_date = Date.today.beginning_of_month
    end_month_date = Date.today.end_of_month

    @total_ever_un_paid_debt = Debtor.total_ever_un_paid_debt
    @damages_ever = Stock.damages_ever
    @complementary_ever = Stock.complementary_ever
    @user_accounts = User.all.count
    @total_products = Product.all.count

    @xaxis = []

    (start_month_date..end_month_date).to_a.each do |date|
      @xaxis << date.strftime("%Y-%m-%d")
    end

    @total_sales = []
    (start_month_date..end_month_date).to_a.each do |date|
      stock_stats_by_date = Product.stock_stats_by_date(date)
      @total_sales << stock_stats_by_date["total_sales"]
    end

    #start_year_date = Date.today.beginning_of_year
    #end_year_date = Date.today.end_of_year
    @running_out_of_stock = Product.running_out_of_stock
    @products_not_in_stock = Product.products_not_in_stock
    @products_with_enough_stock = Product.products_with_enough_stock

  end

  def products_running_out_of_stock
    @page_header = "Products running out of stock"
    @products = Product.running_out_of_stock
  end

  def products_not_in_stock
    @page_header = "Products not in stock"
    @products = Product.products_not_in_stock
  end

  def products_with_enough_stock
    @page_header = "Products with enough stock"
    @products = Product.products_with_enough_stock
  end

  def debtors
    @page_header = "Debtors"
    @debtors = Debtor.unpaid_debts_records
  end

  def new_stock
    @page_header = "New stock"
    @products = Product.order("product_id DESC")
    if request.post?
      stock_in = StockIn.new
      stock_in.product_id = params[:stock][:product_id]
      stock_in.quantity = params[:stock][:quantity]
      stock_in.date_in = params[:stock][:date]

      if stock_in.save
        flash[:notice] = "Stock was updated successfully"
        redirect_to("/product_stock_details?product_id=#{params[:stock][:product_id]}") and return
      else
        flash[:error] = stock_in.errors.full_messages.join('<br />')
        redirect_to("/product_stock_details?product_id=#{params[:stock][:product_id]}") and return
      end

    end
  end

  def adjust_stock
    @page_header = "Adjust stock"
    @products = Product.order("product_id DESC")
    @reasons = ["Sold", "Damaged", "Stolen"]
    if request.post?
      stock_out = StockOut.new
      stock_out.product_id = params[:stock][:product_id]
      stock_out.quantity = params[:stock][:quantity]
      stock_out.date_out = params[:stock][:date]
      stock_out.reason = params[:stock][:reason]

      if stock_out.save
        flash[:notice] = "Stock was updated successfully"
        redirect_to("/product_stock_details?product_id=#{params[:stock][:product_id]}") and return
      else
        flash[:error] = stock_out.errors.full_messages.join('<br />')
        redirect_to("/product_stock_details?product_id=#{params[:stock][:product_id]}") and return
      end
    end
  end

  def view_stock
    @page_header = "View stock"
    if (params[:q])
      @products = Product.search_products(params[:q])
    else
      @products = Product.order("product_id DESC")
    end
  end


  def product_stock_details
    @product = Product.find(params[:product_id])
    @page_header = "#{@product.name} stock details"
    @product_stock_ins = @product.stock_ins.order("DATE(date_in) DESC")
    @product_stock_outs = @product.stock_outs.order("DATE(date_out) DESC")
  end

  def void_incoming_stock
    if request.post?
      stock_in = StockIn.find(params[:stock_in_id])
      stock_in.delete
      flash[:notice] = "You have successfully removed the record from the system"
      redirect_to("/product_stock_details?product_id=#{params[:product_id]}") and return
    end
  end

  def void_outgoing_stock
    if request.post?
      stock_out = StockOut.find(params[:stock_out_id])
      stock_out.delete
      flash[:notice] = "You have successfully removed the record from the system"
      redirect_to("/product_stock_details?product_id=#{params[:product_id]}") and return
    end
  end

  def get_incoming_stock
    product = Product.find(params[:product_id])
    stock_ins = product.stock_ins.order("DATE(date_in) DESC")
    render json: stock_ins.to_json
  end

  def get_outgoing_stock
    product = Product.find(params[:product_id])
    stock_outs = product.stock_outs.order("DATE(date_out) DESC")
    render json: stock_outs.to_json
  end

  def void_stock
    @page_header = "Void stock"
  end

  def set_prices
    @page_header = "Set prices"
    if (params[:q])
      @products = Product.search_products(params[:q])
    else
      @products = Product.order("product_id DESC")
    end

  end

  def manage_product_prices
    @product = Product.find(params[:product_id])
    @page_header = "Managing prices of #{@product.name}"
    @price_histories = @product.price_histories.order("price_history_id DESC")
    if request.post?
      price_history = PriceHistory.new
      price_history.product_id = @product.product_id
      price_history.price = params[:product][:price]
      price_history.start_date = params[:product][:start_date]
      product_price_histories = @product.price_histories.order("DATE(start_date) DESC")
      start_date_collides = false
      new_start_date = params[:product][:start_date].to_date
      product_price_histories.each do |old_price_history|
        start_date = old_price_history.start_date.to_date
        end_date = old_price_history.end_date.to_date rescue start_date
        if end_date >= new_start_date
          start_date_collides = true
          break
        end
      end

      if start_date_collides
        flash[:error] = "The new start date is colliding with previous dates of another price of the same product"
        redirect_to("/manage_product_prices?product_id=#{params[:product_id]}") and return
      end

      ActiveRecord::Base.transaction do
        PriceHistory.set_price_end_dates(params[:product_id], (params[:product][:start_date].to_date - 1.day))
        if price_history.save
          flash[:notice] = "Price for #{@product.name} was set"
          redirect_to("/manage_product_prices?product_id=#{@product.product_id}") and return
        else
          flash[:error] = price_history.errors.full_messages.join('<br />')
          redirect_to("/manage_product_prices?product_id=#{@product.product_id}") and return
        end
      end
    end
  end

  def view_prices
    @page_header = "View prices"
    @price_histories = PriceHistory.order("price_history_id DESC")
  end

  def void_prices
    @page_header = "Void prices"
    @price_histories = PriceHistory.order("price_history_id DESC")
    if request.post?
      price_history = PriceHistory.find(params[:price_history_id])
      price_history.delete
      flash[:notice] = "Price deleted"
      if params[:product_id]
        redirect_to("/manage_product_prices?product_id=#{params[:product_id]}") and return
      else
        redirect_to("/void_prices") and return
      end

    end
  end

  def new_products
    @page_header = "New products"
    @categories = Category.all
    if request.post?
      new_product = Product.new
      new_product.name = params[:product][:name]
      new_product.label = params[:product][:product_label]
      new_product.part_number = params[:product][:part_number]
      new_product.starting_inventory = params[:product][:starting_inventory]
      new_product.minimum_required = params[:product][:minimum_required]

      if new_product.save
        product_category = ProductCategory.new
        product_category.category_id = params[:product][:category_id]
        product_category.product_id = new_product.product_id
        product_category.save

        flash[:notice] = "New product was created"
        redirect_to("/new_products") and return
      else
        flash[:error] = new_product.errors.full_messages.join('<br />')
        redirect_to("/new_products") and return
      end

    end
  end

  def edit_this_product
    @product = Product.find(params[:product_id])
    @page_header = "Editing products - #{@product.name}"
    @categories = Category.all
    if request.post?
      @product.name = params[:product][:name]
      @product.label = params[:product][:product_label]
      @product.part_number = params[:product][:part_number]
      @product.starting_inventory = params[:product][:starting_inventory]
      @product.minimum_required = params[:product][:minimum_required]

      if @product.save
        product_category = @product.product_category
        product_category = ProductCategory.new if product_category.blank?
        product_category.category_id = params[:product][:category_id]
        product_category.product_id = @product.product_id
        product_category.save

        flash[:notice] = "#{@product.name} was updated successfully"
        redirect_to("/edit_products") and return
      else
        flash[:error] = @product.errors.full_messages.join('<br />')
        redirect_to("/edit_products") and return
      end

    end
  end

  def edit_products
    @page_header = "Edit products"
    if (params[:q])
      @products = Product.search_products(params[:q])
    else
      @products = Product.order("product_id DESC")
    end
  end

  def view_products
    @page_header = "View products"
    if (params[:q])
      @products = Product.search_products(params[:q])
    else
      @products = Product.order("product_id DESC")
    end
  end

  def void_products
    @page_header = "Void products"

    if (params[:q])
      @products = Product.search_products(params[:q])
    else
      @products = Product.order("product_id DESC")
    end

    if request.post?
      product = Product.find(params[:product_id])
      product.voided = 1
      product.voided_by = 1
      product.date_voided = Date.today
      if product.save
        flash[:notice] = "#{product.name} was voided successfully"
        redirect_to("/void_products") and return
      else
        flash[:error] = product.errors.full_messages.join('<br />')
        redirect_to("/void_products") and return
      end
    end
  end

  def reports
    @page_header = "Reports"
  end

  def stock_card
    @page_header = "Stock card"
    @products = Product.order("product_id DESC")
    @today = params[:stock_date].to_date.strftime("%d/%m/%Y") rescue Date.today.strftime("%d/%m/%Y")

    @standard_products = Product.standard_items
    @non_standard_products = Product.non_standard_items

    @last_stock_id = Stock.where(["DATE(stock_time) = ?", @today.to_date]).order("stock_id DESC").first.stock_id rescue nil
    if params[:stock_id]
      @last_stock_id = params[:stock_id]
    end
    #@last_stock_id = Stock.where(["DATE(stock_time) <= ?", @today.to_date]).order("stock_id DESC").first.stock_id rescue nil
    @stock_cards = Stock.where(["DATE(stock_time) = ?", @today.to_date])
    @debtors = Debtor.where(["DATE(date) = ?", @today.to_date])
    @stock_stats_by_date = Product.stock_stats_by_date(@today, @last_stock_id)
    @total_debts = Debtor.total_debts_by_date(@today)
    @actual_cash = Stock.find(@last_stock_id).amount_collected.to_f rescue "0"
  end

  def edit_stock_card
    @products = Product.order("product_id DESC")
    @today = params[:stock_date].to_date.strftime("%d/%m/%Y") rescue Date.today.strftime("%d/%m/%Y")
    @page_header = "Editing stock card dated #{@today}"
    @standard_products = Product.standard_items
    @non_standard_products = Product.non_standard_items

    @last_stock_id = Stock.where(["DATE(stock_time) = ?", @today.to_date]).order("stock_id DESC").first.stock_id rescue nil
    if params[:stock_id]
      @last_stock_id = params[:stock_id]
    end
    @debtors = Debtor.where(["DATE(date) = ?", @today.to_date])
    @stock_stats_by_date = Product.stock_stats_by_date(@today, @last_stock_id)
    @total_debts = Debtor.total_un_paid_debt(@today)
    @stock_cards = []
  end

  def update_stock
    stock_date = params[:stock_date]

    stock = Stock.find(params[:stock_id])
    stock.user_id = params[:user_id]
    stock.save

    params[:products].each do |product_id, values|
      closing_amount = values["stock"]
      closing_shots = values["shots"]
      damaged_stock = values["damage"]
      product = Product.find(product_id)

      if product.category_name.match(/NON/i)
        closing_shots = closing_amount
        closing_amount = opening_stock_by_date - closing_amount.to_i - damaged_stock.to_i - complementary_stock.to_i
      end

      stock_item = StockItem.where(["stock_id =? AND product_id =?", params[:stock_id], product_id]).last
      stock_item = StockItem.new if stock_item.blank?
      stock_item.stock_id = stock.stock_id
      stock_item.product_id = product_id

      if stock_item.opening_stock.blank?
        opening_stock_by_date = product.opening_stock_by_date(params[:stock_date], params[:stock_id])
        stock_item.opening_stock = opening_stock_by_date
      end

      unless closing_shots.blank?
        stock_item.shots_sold = closing_shots
      end

      unless closing_amount.blank?
        stock_item.closing_stock = closing_amount
      end

      unless damaged_stock.blank?
        stock_item.damaged_stock = damaged_stock
      end

      stock_item.save
    end

    flash[:notice] = "You have successfully closed the stock card"
    redirect_to("/stock_card?stock_date=#{stock_date}") and return

  end

  def add_stock
    @page_header = "Add stock"
    @product = Product.find(params[:product_id])
    if request.post?
      stock_card = @product.stock_card_by_date(params[:stock][:stock_date])
      stock_card = StockCard.new if stock_card.blank?
      stock_card.added_stock = params[:stock][:quantity]
      stock_card.product_id = params[:product_id]
      stock_card.date = params[:stock][:stock_date]
      if stock_card.save
        flash[:notice] = "Items were added successfully"
        redirect_to("/stock_card?stock_date=#{params[:stock][:stock_date]}") and return
      else
        flash[:error] = stock_card.errors.full_messages.join('<br />')
        redirect_to("/add_stock?product_id=#{params[:product_id]}&stock_date=#{params[:stock][:stock_date]}") and return
      end

    end
  end

  def modify_stock
    product_addition = ProductAddition.new
    product_addition.added_stock = params[:quantity]
    product_addition.product_id = params[:product_id]
    product_addition.date_added = params[:stock_date]
    product_addition.save
    data = {}
    product = Product.find(params[:product_id])
    data["current_stock"] = product.current_stock(params[:stock_date], params[:stock_id])
    render json: data.to_json
  end

  def create_stock
    settings = YAML.load_file(Rails.root.to_s + "/config/settings.yml")["settings"]
    recipients = settings["recipients"].split(", ")
    stock_date = params[:stock_date]
    stock = Stock.new
    stock.user_id = params[:user_id]
    stock.stock_time = stock_date
    stock.amount_collected = params[:actual_cash]
    if stock.save
      params[:products].each do |product_id, values|
        closing_amount = values["stock"]
        #closing_shots = values["shots"]
        closing_shots = ""
        damaged_stock = values["damage"]
        complementary_stock = values["complementary"]

        product = Product.find(product_id)
        opening_stock_by_date = product.opening_stock_by_date(params[:stock_date])
        added_stock_by_date = product.added_stock_by_date(params[:stock_date])
        stock_item = StockItem.new
        if product.category_name.match(/NON/i)
          closing_shots = closing_amount
          closing_amount = (opening_stock_by_date + added_stock_by_date) - closing_amount.to_i - damaged_stock.to_i - complementary_stock.to_i
        end
        stock_item.stock_id = stock.stock_id
        stock_item.product_id = product_id
        stock_item.opening_stock = opening_stock_by_date
        stock_item.shots_sold = closing_shots
        stock_item.damaged_stock = damaged_stock
        stock_item.complementary_stock = complementary_stock
        stock_item.closing_stock = closing_amount
        stock_item.save
      end

      products_running_out_of_stock = Product.running_out_of_stock
      products_not_in_stock = Product.products_not_in_stock
      debtors = Debtor.where(["DATE(date) = ?", stock_date.to_date])
      recipients.each do |recipient|
        recipient_split = recipient.split(":")
        name = recipient_split[0]
        email = recipient_split[1]

        NotificationMailer.sales_summary(stock_date, email, name).deliver_later
        NotificationMailer.products_running_low(email, name).deliver_later unless products_running_out_of_stock.blank?
        NotificationMailer.products_out_of_stock(email, name).deliver_later unless products_not_in_stock.blank?
        NotificationMailer.debtors(stock_date, email, name).deliver_later unless debtors.blank?
      end

      flash[:notice] = "You have successfully closed the stock card"
      redirect_to("/stock_card?stock_date=#{stock_date}") and return
    else
      flash[:error] = stock.errors.full_messages.join('<br />')
      redirect_to("/stock_card?stock_date=#{stock_date}") and return
    end
  end

  def get_product_details
    @product = Product.find(params[:product_id])
    data = {
        :product_name => @product.name,
        :opening_stock => @product.opening_stock_by_date(params[:date].to_date),
        :minimum_required => @product.minimum_required,
        :date_of_stock => params[:date].to_date.strftime("%d/%b/%Y"),
    }
    product_additions = @product.product_additions.where(["DATE(date_added) =?", params[:date].to_date])
    data = {:product_details => data, :product_additions => product_additions}
    render json: data.to_json
  end

  def void_product_additions
    product_addition = ProductAddition.find(params[:product_addition_id])
    product_addition.voided = 1
    product_addition.date_voided = Date.today
    product_addition.voided_by = session[:user]["user_id"]
    if product_addition.save
      render json: {success: true}.to_json
    else
      render json: {success: false}.to_json
    end
  end

  def close_stock
    @page_header = "Close stock"
    @product = Product.find(params[:product_id])
    if request.post?
      stock_card = @product.stock_card_by_date(params[:stock][:stock_date])
      stock_card = StockCard.new if stock_card.blank?
      stock_card.closing_stock = params[:stock][:quantity]
      stock_card.product_id = params[:product_id]
      stock_card.date = params[:stock][:stock_date]
      if stock_card.save
        flash[:notice] = "Stock was closed successfully"
        redirect_to("/stock_card?stock_date=#{params[:stock][:stock_date]}") and return
      else
        flash[:error] = stock_card.errors.full_messages.join('<br />')
        redirect_to("/close_stock?product_id=#{params[:product_id]}&stock_date=#{params[:stock][:stock_date]}") and return
      end
    end
  end

  def add_products
    product_addition = ProductAddition.new
    product_addition.added_stock = params[:stock][:quantity]
    product_addition.product_id = params[:stock][:product_id]
    product_addition.date_added = params[:stock][:stock_date]
    if product_addition.save
      flash[:notice] = "Items were added successfully"
      redirect_to("/stock_card?stock_date=#{params[:stock][:stock_date]}") and return
    else
      flash[:error] = product_addition.errors.full_messages.join('<br />')
      redirect_to("/stock_card?stock_date=#{params[:stock][:stock_date]}") and return
    end

  end

  def create_debtors
    debtor = Debtor.new
    debtor.name = params[:name]
    debtor.amount_owed = params[:amount]
    debtor.description = params[:description]
    debtor.date = params[:date]

    if debtor.save
      data = {:data => debtor.to_json, :status => "success"}
      render json: data.to_json
    else
      errors = debtor.errors.full_messages.join('<br />')
      data = {:data => errors, :status => "fail"}
      render json: data.to_json
    end

  end

  def void_debtors
    debtor = Debtor.find(params[:debtor_id])
    debtor.delete
    render text: "success"
  end


  def get_product_data
    products = Product.all
    data = {}
    debts = Stock.debtors(params[:stock_date], @last_stock_id)
    products.each do |product|
      product_id = product.product_id
      data[product_id] = {}
      data[product_id]["current_stock"] = product.current_stock(params[:stock_date], @last_stock_id)
      data[product_id]["current_price"] = product.price(params[:stock_date])
      data[product_id]["debts"] = debts
    end
    render json: data.to_json
  end

  def get_product_stock_data
    data = {}
    product = Product.find(params[:product_id])
    data["current_stock"] = product.current_stock(params[:stock_date], params[:stock_id])
    data["current_price"] = product.price(params[:stock_date])
    render json: data.to_json
  end

  def get_previous_debt_payments
    debtor = Debtor.find(params[:debtor_id])
    render json: debtor.debtor_payments.to_json
  end

  def create_debtor_payment
    debtor_payment = DebtorPayment.new
    debtor_payment.debtor_id = params[:debtor_id]
    debtor_payment.amount_paid = params[:amount_paid]
    debtor_payment.date_paid = Date.today

    if debtor_payment.save
      debtor = Debtor.find(params[:debtor_id])
      amount_paid = debtor.amount_paid
      balance_due = debtor.balance_due

      data = {:amount_paid => amount_paid, :balance_due => balance_due, :status => "success"}
      render json: data.to_json
    else
      errors = debtor_payment.errors.full_messages.join('<br />')
      data = {:errors => errors, :status => "fail"}
      render json: data.to_json
    end

  end

end
