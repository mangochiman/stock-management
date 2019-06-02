class NotificationMailer < ApplicationMailer
  default from: "Bar stock update <barstocknotifications@gmail.com>"

  def sales_summary(date, email, name)
    @date = date
    @name = name
    @total_debts = Debtor.total_un_paid_debt(date)
    @sales_summary = Product.stock_stats_by_date(date)
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

end