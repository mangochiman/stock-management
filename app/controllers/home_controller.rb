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
    if request.post?
      new_product = Product.new
      new_product.name = params[:product][:name]
      new_product.label = params[:product][:product_label]
      new_product.part_number = params[:product][:part_number]
      new_product.starting_inventory = params[:product][:starting_inventory]
      new_product.minimum_required = params[:product][:minimum_required]

      if new_product.save
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
    if request.post?
      @product.name = params[:product][:name]
      @product.label = params[:product][:product_label]
      @product.part_number = params[:product][:part_number]
      @product.starting_inventory = params[:product][:starting_inventory]
      @product.minimum_required = params[:product][:minimum_required]

      if @product.save
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

end
