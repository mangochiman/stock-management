class PasswordReminder < ActiveRecord::Base
  self.table_name = "password_reminders"
  self.primary_key = "password_reminder_id"

  belongs_to :user, :foreign_key => :user_id

  default_scope {where ("voided = 0")}
end
