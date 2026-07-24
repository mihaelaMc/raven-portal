# Preview these at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.welcome_email(preview_user)
  end

  def security_alert
    UserMailer.security_alert(preview_user)
  end

  private

  def preview_user
    User.new(crawler_name: "Grix", email: "grix@example.com")
  end
end
