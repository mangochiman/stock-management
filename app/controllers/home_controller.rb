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
  end

  def edit_products
    @page_header = "Edit products"
  end

  def view_products
    @page_header = "View products"
  end

  def void_products
    @page_header = "Void products"
  end

  def reports
    @page_header = "Reports"
  end

end
