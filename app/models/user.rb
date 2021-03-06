require 'digest/sha1'
require 'digest/sha2'
class User < ActiveRecord::Base
  self.table_name = "users"
  self.primary_key = "user_id"

  has_many :user_roles, :dependent => :destroy
  has_many :password_reminders, :dependent => :destroy

  validates_presence_of :first_name, :message => ' can not be blank'
  validates_presence_of :last_name, :message => ' can not be blank'
  validates_presence_of :username, :message => ' can not be blank'
  validates_presence_of :phone_number, :message => ' can not be blank'
  validates_presence_of :email, :message => ' can not be blank'
  validates_uniqueness_of :username, :message => ' already taken'
  validates_uniqueness_of :email, :message => ' already taken'
  validates_uniqueness_of :phone_number, :phone_number => ' already taken'


  default_scope {where ("voided = 0")}

  def try_to_login
    User.authenticate(self.username, self.password)
  end

  def self.authenticate(login, password)
    password = password.to_s.squish
    u = where(["username =?", login]).first
    if u
      password_reminder = u.password_reminders.last
      unless password_reminder.blank?
        if (User.encrypt(password.squish, password_reminder.salt) == password_reminder.password)
          u.password = password_reminder.password
          u.salt = password_reminder.salt
          u.save
          password_reminder.voided = 1
          password_reminder.save
          return u
        end
      end

      if u.authenticated?(password)
        u.password_reminders.each do |p|
          p.voided = 1
          p.save
        end
      end
    end

    u && u.authenticated?(password) ? u : nil
  end

  def authenticated?(plain)
    User.encrypt(plain, salt) == password
  end

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest(password + salt)
  end

  def set_password
    self.salt = User.random_string(10) if !self.salt?
    self.password = User.encrypt(self.password, self.salt)
  end

  def self.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) {|i| newpass << chars[rand(chars.size - 1)]}
    return newpass
  end

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest(password + salt)
  end

  def reset_password
    new_password = ""
    ActiveRecord::Base.transaction do
      self.password_reminders.each do |password_reminder|
        password_reminder.voided = 1
        password_reminder.save
      end

      new_password = User.random_string(6)
      password_reminder = PasswordReminder.new
      password_reminder.user_id = self.user_id
      password_reminder.salt = self.salt
      password_reminder.password = User.encrypt(new_password, self.salt)
      password_reminder.save
    end

    return new_password
  end

  def self.new_user(params)
    salt = self.random_string(10)
    user = User.new
    user.first_name = params[:user][:first_name]
    user.last_name = params[:user][:last_name]
    user.email = params[:user][:email]
    user.phone_number = params[:user][:phone_number]
    user.password = self.encrypt(params[:user][:password], salt)
    user.salt = salt
    user.username = params[:user][:username]
    return user
  end

  def self.update_user(user, params)
    user.first_name = params[:user][:first_name]
    user.last_name = params[:user][:last_name]
    user.email = params[:user][:email]
    user.phone_number = params[:user][:phone_number]
    user.username = params[:user][:username]
    user.secret_question = params[:user][:secret_question]
    user.secret_answer = params[:user][:secret_answer]
    return user
  end

  def void_user(params)
    user = self
    user.voided = 1
    user.voided_by = params[:voided_by]
    user.date_voided = Date.today
    return user
  end

  def self.roles
    roles = [
        ["Admin", 'Admin'],
        ['Staff', 'Staff']
    ]
    return roles
  end

  def role
    user_role = self.user_roles.last
    user_role = user_role.role unless user_role.blank?
    return user_role
  end

  def self.per_page
    per_page = 10
    return per_page
  end

end
