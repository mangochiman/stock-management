class UserRole < ActiveRecord::Base

  def self.create_user_role(user, params)
    user_role = UserRole.new
    user_role.user_id = user.user_id
    user_role.role = params[:user][:role]
    user_role.save
  end
end
