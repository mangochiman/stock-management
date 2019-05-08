class HomeController < ApplicationController
  def home
    @page_header = "Dashboard"
  end

  def new_stock
    @page_header = "New stock"
  end

  def adjust_stock
    @page_header = "Adjust stock"
  end

  def view_stock
    @page_header = "View stock"
  end

  def void_stock
    @page_header = "Void stock"
  end

  def set_prices
    @page_header = "Set prices"
  end

  def view_prices
    @page_header = "View prices"
  end

  def void_prices
    @page_header = "Void prices"
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
    @products = Product.order("product_id DESC")
  end

  def view_products
    @page_header = "View products"
    @products = Product.order("product_id DESC")
  end

  def void_products
    @page_header = "Void products"
    @products = Product.order("product_id DESC")
  end

  def reports
    @page_header = "Reports"
  end

end
