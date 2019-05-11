class ReportsController < ApplicationController
  before_filter :authorize, :except => [:incoming_stock_report_printable]

  def incoming_stock_report
    @page_header = "Incoming stock report"
    @products = Product.order("product_id DESC")
    if request.post?
      start_date = params[:start_date]
      end_date = params[:end_date]
      product = Product.find(params[:product_id])
      data = product.get_incoming_stock_report(start_date, end_date)
      render json: data.to_json
    end
  end

  def incoming_stock_report_printable
    @page_header = "Incoming stock report"
    @products = Product.order("product_id DESC")
    start_date = params[:start_date]
    end_date = params[:end_date]
    product = Product.find(params[:product_id])
    @data = product.get_incoming_stock_report(start_date, end_date)
    render layout: false
  end

  def products_with_enough_stock_report
    @page_header = "Products with enough stock report"
    @products = Product.products_with_enough_stock
  end

  def outgoing_stock_report
    @page_header = "Outgoing stock report"
    @products = Product.order("product_id DESC")
    if request.post?
      start_date = params[:start_date]
      end_date = params[:end_date]
      product = Product.find(params[:product_id])
      data = product.get_outgoing_stock_report(start_date, end_date)
      render json: data.to_json
    end
  end

  def products_not_in_stock_report
    @page_header = "Products not in stock report"
    @products = Product.products_not_in_stock
  end

  def products_running_out_of_stock_report
    @page_header = "Products running out of stock report"
    @products = Product.running_out_of_stock
  end

end
