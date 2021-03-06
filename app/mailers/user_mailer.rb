class UserMailer < ApplicationMailer
  before_action :set_attributes
  def welcome
    mail to: @email_with_name, subject: "Hi #{@user.name}, welcome to Quind!"
  end

  def forgot_password
    mail to: @email_with_name, subject: "Hi #{@user.name}, #{@user.reset_password_token} is your reset password token"
  end

  def change_email
    mail to: @email_with_name, subject: "Hi #{@user.name}, your email change succeeds!"
  end

  def policy_registered
    mail to: @email_with_name, subject: "Hi #{@user.name}, your policy has been registered!"
  end

  private

  def set_attributes
    @user = params[:user]
    @policy = params[:policy]
    @email_with_name = %("#{@user.name}" <#{@user.email}>)
  end
end
