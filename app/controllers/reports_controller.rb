class ReportsController < ApplicationController
  before_filter :authorize, :except => [:incoming_stock_report_printable,
                                        :print_incoming_stock_report_printable,
                                        :products_with_enough_stock_report_printable,
                                        :outgoing_stock_report_printable,
                                        :products_running_out_of_stock_report_printable,
                                        :products_not_in_stock_report_printable]

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
    start_date = params[:start_date]
    end_date = params[:end_date]
    @product = Product.find(params[:product_id])
    @data = @product.get_incoming_stock_report(start_date, end_date)
    render layout: false
  end

  def print_incoming_stock_report_printable
    product_id = params[:product_id]
    start_date = params[:start_date]
    end_date = params[:end_date]

    file_name = "product_#{product_id}"
    t1 = Thread.new {
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
                        request.env["HTTP_HOST"] + "\"/incoming_stock_report_printable?product_id=#{product_id}&start_date=#{start_date}&end_date=#{end_date}" + "\" /tmp/#{file_name}" + ".pdf \n"
    }
    t1.join

    pdf_filename = "/tmp/#{file_name}.pdf"
    send_file(pdf_filename, :filename => "#{file_name}", :type => "application/pdf")
  end

  def sales_report
    @page_header = "Sales report"
    @products = Product.order("product_id DESC")
    if request.post?
      start_date = params[:start_date]
      end_date = params[:end_date]
      #product = Product.find(params[:product_id])
      #data = product.get_incoming_stock_report(start_date, end_date)
      #render json: data.to_json
    end
  end

  def products_with_enough_stock_report
    @page_header = "Products with enough stock report"
    @products = Product.products_with_enough_stock
  end

  def products_with_enough_stock_report_printable
    @products = Product.products_with_enough_stock
    render layout: false
  end

  def print_products_with_enough_stock_report_printable
    file_name = "product_all"
    t1 = Thread.new {
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
                        request.env["HTTP_HOST"] + "\"/products_with_enough_stock_report_printable" + "\" /tmp/#{file_name}" + ".pdf \n"
    }
    t1.join

    pdf_filename = "/tmp/#{file_name}.pdf"
    send_file(pdf_filename, :filename => "#{file_name}", :type => "application/pdf")
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

  def outgoing_stock_report_printable
    start_date = params[:start_date]
    end_date = params[:end_date]
    @product = Product.find(params[:product_id])
    @data = @product.get_outgoing_stock_report(start_date, end_date)
    render layout: false
  end

  def print_outgoing_stock_report_printable
    product_id = params[:product_id]
    start_date = params[:start_date]
    end_date = params[:end_date]

    file_name = "product_outgoing_stock_#{product_id}"
    t1 = Thread.new {
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
                        request.env["HTTP_HOST"] + "\"/outgoing_stock_report_printable?product_id=#{product_id}&start_date=#{start_date}&end_date=#{end_date}" + "\" /tmp/#{file_name}" + ".pdf \n"
    }
    t1.join

    pdf_filename = "/tmp/#{file_name}.pdf"
    send_file(pdf_filename, :filename => "#{file_name}", :type => "application/pdf")
  end

  def products_not_in_stock_report
    @page_header = "Products not in stock report"
    @products = Product.products_not_in_stock
  end

  def products_not_in_stock_report_printable
    @products = Product.products_not_in_stock
    render layout: false
  end

  def print_products_not_in_stock_report_printable
    file_name = "products_not_in_stock_all"
    t1 = Thread.new {
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
                        request.env["HTTP_HOST"] + "\"/products_not_in_stock_report_printable" + "\" /tmp/#{file_name}" + ".pdf \n"
    }
    t1.join

    pdf_filename = "/tmp/#{file_name}.pdf"
    send_file(pdf_filename, :filename => "#{file_name}", :type => "application/pdf")
  end

  def products_running_out_of_stock_report
    @page_header = "Products running out of stock report"
    @products = Product.running_out_of_stock
  end

  def products_running_out_of_stock_report_printable
    @products = Product.running_out_of_stock
    render layout: false
  end

  def print_products_running_out_of_stock_report_printable
    file_name = "products_running_of_stock_all"
    t1 = Thread.new {
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
                        request.env["HTTP_HOST"] + "\"/products_running_out_of_stock_report_printable" + "\" /tmp/#{file_name}" + ".pdf \n"
    }
    t1.join

    pdf_filename = "/tmp/#{file_name}.pdf"
    send_file(pdf_filename, :filename => "#{file_name}", :type => "application/pdf")
  end

end
