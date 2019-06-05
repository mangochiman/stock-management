class NotificationMailer < ApplicationMailer
  default from: "Bar stock update <barstocknotifications@gmail.com>"

  def sales_summary(date, email, name)
    @date = date
    @name = name
    @total_debts = Debtor.total_un_paid_debt(date)
    @sales_summary = Product.stock_stats_by_date(date)
    stock_id = Stock.where(["DATE(stock_time) = ? ", date.to_date]).last.stock_id rescue nil
    @actual_cash = Stock.find(stock_id).amount_collected.to_f rescue 0

    mail(
        to: email,
        subject: "SALES SUMMARY"
    )
  end

  def products_running_low(email, name)
    @name = name
    @products = Product.running_out_of_stock
    mail(
        to: email,
        subject: "PRODUCTS RUNNING OUT OF STOCK"
    )
  end

  def products_out_of_stock(email, name)
    @name = name
    @products = Product.products_not_in_stock
    mail(
        to: email,
        subject: "PRODUCTS OUT OF STOCK"
    )
  end

  def reset_password(user, new_password)
    @name = user.first_name
    @new_password = new_password
    mail(
        to: user.email,
        subject: "PASSWORD RESET"
    )
  end

end
