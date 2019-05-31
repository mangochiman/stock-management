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
end
