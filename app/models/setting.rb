class Setting < ActiveRecord::Base
  self.primary_key = "setting_id"
  self.table_name = "settings"
end
