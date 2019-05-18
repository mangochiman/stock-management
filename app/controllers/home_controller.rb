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

    #start_year_date = Date.today.beginning_of_year
    #end_year_date = Date.today.end_of_year

    @this_weeks_incoming_stock = Product.incoming_stock_by_date_range(start_week_date, end_week_date).count
    @this_months_incoming_stock = Product.incoming_stock_by_date_range(start_month_date, end_month_date).count

    @this_weeks_outgoing_stock = Product.outgoing_stock_by_date_range(start_week_date, end_week_date).count
    @this_months_outgoing_stock = Product.outgoing_stock_by_date_range(start_month_date, end_month_date).count

    @running_out_of_stock = Product.running_out_of_stock
    @products_not_in_stock = Product.products_not_in_stock
    @products_with_enough_stock = Product.products_with_enough_stock

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
    if request.post?
      price_history = PriceHistory.new
      price_history.product_id = @product.product_id
      price_history.price = params[:product][:price]
      price_history.start_date = params[:product][:start_date]
      price_history.end_date = params[:product][:end_date]

      if price_history.save
        flash[:notice] = "Price for #{@product.name} was set"
        redirect_to("/manage_product_prices?product_id=#{@product.product_id}") and return
      else
        flash[:error] = price_history.errors.full_messages.join('<br />')
        redirect_to("/manage_product_prices?product_id=#{@product.product_id}") and return
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
    #@last_stock_id = Stock.where(["DATE(stock_time) <= ?", @today.to_date]).order("stock_id DESC").first.stock_id rescue nil
    @stock_cards = Stock.where(["DATE(stock_time) = ?", @today.to_date])
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

  def create_stock
    stock_date = params[:stock_date]
    stock = Stock.new
    stock.user_id = params[:user_id]
    stock.stock_time = stock_date
    if stock.save
      params[:products].each do |product_id, closing_amount|
        product = Product.find(product_id)
        opening_stock_by_date = product.opening_stock_by_date(params[:stock_date])
        stock_item = StockItem.new
        stock_item.stock_id = stock.stock_id
        stock_item.product_id = product_id
        stock_item.opening_stock = opening_stock_by_date
        stock_item.closing_stock = closing_amount
        stock_item.save
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
        :opening_stock => "",
        :minimum_required => "",
        :date_of_stock => "",
    }
    product_additions = @product.product_additions.where(["DATE(date_added) =?", params[:date].to_date])
    data = {:product_details => data, :product_additions => product_additions}
    render json: data.to_json
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

end
