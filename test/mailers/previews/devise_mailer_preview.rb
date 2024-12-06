class DeviseMailerPreview < ActionMailer::Preview
  
  # http://localhost:3000/rails/mailers/devise_mailer/reset_password_instructions
  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(User.first, "faketoken")
  end

  # http://localhost:3000/rails/mailers/devise_mailer/email_changed
  def email_changed
    Devise::Mailer.email_changed(User.first)
  end

  # http://localhost:3000/rails/mailers/devise_mailer/password_changed
  def password_changed
    Devise::Mailer.password_change(User.first)
  end
end