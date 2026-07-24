class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "You have been selected for entry")
  end

  def security_alert(user)
    @user = user
    mail(to: user.email, subject: "Your password was just changed")
  end
end
