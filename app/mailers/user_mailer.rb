class UserMailer < ApplicationMailer
  def user_welcome(user)
    @user = user
    @sign_in = user_session_url
    @plans = plans_url
    mail( to: @user.email, subject: 'Welcome')
  end
end