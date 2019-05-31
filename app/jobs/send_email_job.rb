class SendEmailJob < ActiveJob::Base
  queue_as :default

  def perform(stock_date, email, name)
    # Do something later
    NotificationMailer.sales_summary(stock_date, email, name).deliver_later
    NotificationMailer.products_running_low(email, name).deliver_later
    NotificationMailer.products_out_of_stock(email, name).deliver_later
  end
end
