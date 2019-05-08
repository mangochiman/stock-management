class UsersController < ApplicationController
  def login
    render layout: false
  end

  def new_user
    @page_header = "New user"
    @roles = User.roles
    if request.post?
      password = params[:user][:password]
      password_confirm = params[:user][:confirm_password]

      if (password != password_confirm)
        flash[:error] = "Password Mismatch"
        redirect_to("/new_user") and return
      end
      user = User.new_user(params)

      if user.save
        UserRole.create_user_role(user, params)

        flash[:notice] = "Account creation was successful"
        redirect_to("/new_user") and return
      else
        flash[:error] = user.errors.full_messages.join('<br />')
        redirect_to("/new_user") and return
      end
    end
  end

  def edit_user
    @page_header = "Edit user"
    @users = User.all
  end

  def view_users
    @page_header = "View users"
    @users = User.all
  end

  def void_users
    @page_header = "Void users"
    @users = User.all
    if request.post?
      user = User.find(params[:user_id])
      user.void_user(params)
      if user.save
        flash[:notice] = "#{user.username} has been voided"
      else
        flash[:error] = user.errors.full_messages.join('<br />')
      end
      redirect_to("/void_users") and return
    end
  end


  def logout

  end
end
