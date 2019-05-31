class NotificationMailer < ApplicationMailer
  default from: "Bar stock update <barstocknotifications@gmail.com>"

  def sales_summary(date)
    @date = date
    @total_debts = Debtor.total_un_paid_debt(date)
    @sales_summary = Product.stock_stats_by_date(date)
    mail(
        to: ["mangochiman@gmail.com"],
        subject: "SALES SUMMARY"
    )
  end

  def products_running_low
    @products = Product.Product.running_out_of_stock
    mail(
        to: ["mangochiman@gmail.com"],
        subject: "PRODUCTS RUNNING OUT OF STOCK"
    )
  end

  def products_out_of_stock
    @products = Product.products_not_in_stock
    mail(
        to: ["mangochiman@gmail.com"],
        subject: "PRODUCTS OUT OF STOCK"
    )
  end

end
