class ReportsController < ApplicationController
  before_filter :authorize, :except => [:incoming_stock_report_printable,
                                        :print_incoming_stock_report_printable,
                                        :products_with_enough_stock_report_printable,
                                        :outgoing_stock_report_printable,
                                        :products_running_out_of_stock_report_printable,
                                        :products_not_in_stock_report_printable,
                                        :sales_report_printable
  ]

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
      date = params[:date].to_date
      if params[:product_id].match(/ALL/i)
        products = Product.all
      else
        products = [Product.find(params[:product_id])]
      end
      stock_id = Stock.where(["DATE(stock_time) = ? ", date.to_date]).last.stock_id rescue nil
      data = {}
      products.each do |product|
        product_id = product.product_id
        product_name = product.name
        data[product_id] = {}
        opening_stock = product.opening_stock_by_date(date, stock_id)
        added_stock = product.added_stock_by_date(date, stock_id).to_i
        current_stock = product.current_stock(date, stock_id).to_i
        closing_stock = product.closed_stock_by_date(date, stock_id).to_i
        damaged_stock = product.damaged_stock(stock_id).to_i
        complementary_stock = product.complementary_stock(stock_id).to_i
        difference = current_stock - closing_stock
        current_price = product.price(date)
        stock_stats_by_date_and_product = Product.stock_stats_by_date_and_product(date, product)
        total_sales = stock_stats_by_date_and_product["total_sales"]

        data[product_id]["opening_stock"] = opening_stock
        data[product_id]["added_stock"] = added_stock
        data[product_id]["current_stock"] = current_stock
        data[product_id]["closing_stock"] = closing_stock
        data[product_id]["damaged_stock"] = damaged_stock
        data[product_id]["complementary_stock"] = complementary_stock
        data[product_id]["difference"] = difference
        data[product_id]["current_price"] = current_price
        data[product_id]["total_sales"] = total_sales
        data[product_id]["product_name"] = product_name
      end

      stock_stats_by_date = Product.stock_stats_by_date(date, stock_id)
      total_debts = Debtor.total_debts_by_date(date)
      debtors = Debtor.where(["DATE(date) = ?", date.to_date])
      debts = {}
      debtors.each do |debtor|
        debtor_id = debtor.debtor_id
        debtor_name = debtor.name
        amount_owed = debtor.amount_owed
        amount_paid = debtor.amount_paid
        balance_due = debtor.balance_due
        debts[debtor_id] = {}
        debts[debtor_id]["amount_owed"] = amount_owed
        debts[debtor_id]["amount_paid"] = amount_paid
        debts[debtor_id]["balance_due"] = balance_due
        debts[debtor_id]["name"] = debtor_name
      end

      actual_cash = Stock.find(stock_id).amount_collected.to_f rescue 0

      response = {"stock_card" => data, "debtors" => debts, "total_debts" => total_debts, "stats" => stock_stats_by_date, "actual_cash" => actual_cash}

      render json: response.to_json
    end
  end

  def sales_report_printable
    date = params[:date].to_date
    if params[:product_id].match(/ALL/i)
      products = Product.all
      @product_name = "All"
    else
      selected_product = Product.find(params[:product_id])
      products = [selected_product]
      @product_name = selected_product.name
    end
    stock = Stock.where(["DATE(stock_time) = ? ", date.to_date]).last
    stock_id = stock.stock_id rescue nil

    @authorizer = ""
    unless stock.blank?
      user = User.find(stock.user_id) rescue ""
      @authorizer = (user.first_name.to_s + " " + user.last_name.to_s) rescue ""
    end

    data = {}
    products.each do |product|
      product_id = product.product_id
      product_name = product.name
      data[product_id] = {}
      opening_stock = product.opening_stock_by_date(date, stock_id)
      added_stock = product.added_stock_by_date(date, stock_id).to_i
      current_stock = product.current_stock(date, stock_id).to_i
      closing_stock = product.closed_stock_by_date(date, stock_id).to_i
      damaged_stock = product.damaged_stock(stock_id).to_i
      complementary_stock = product.complementary_stock(stock_id).to_i
      difference = current_stock - closing_stock
      current_price = product.price(date)
      stock_stats_by_date_and_product = Product.stock_stats_by_date_and_product(date, product)
      total_sales = stock_stats_by_date_and_product["total_sales"]

      data[product_id]["opening_stock"] = opening_stock
      data[product_id]["added_stock"] = added_stock
      data[product_id]["current_stock"] = current_stock
      data[product_id]["closing_stock"] = closing_stock
      data[product_id]["damaged_stock"] = damaged_stock
      data[product_id]["complementary_stock"] = complementary_stock
      data[product_id]["difference"] = difference
      data[product_id]["current_price"] = current_price
      data[product_id]["total_sales"] = total_sales
      data[product_id]["product_name"] = product_name
    end

    @stock_stats_by_date = Product.stock_stats_by_date(date, stock_id)
    @total_debts = Debtor.total_debts_by_date(date)
    @debtors = Debtor.where(["DATE(date) = ?", date.to_date])
    @actual_cash = Stock.find(stock_id).amount_collected.to_f rescue 0
    @data = data

    render layout: false
  end

  def print_sales_report_printable
    product_id = params[:product_id]
    date = params[:date]

    file_name = "sales_report"
    t1 = Thread.new {
      Kernel.system "wkhtmltopdf --margin-top 0 --margin-bottom 0 -s A4 http://" +
                        request.env["HTTP_HOST"] + "\"/sales_report_printable?product_id=#{product_id}&date=#{date}" + "\" /tmp/#{file_name}" + ".pdf \n"
    }
    t1.join

    pdf_filename = "/tmp/#{file_name}.pdf"
    send_file(pdf_filename, :filename => "#{file_name}", :type => "application/pdf")
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
