class TypusMailer < ActionMailer::Base

  self.template_root = "#{File.dirname(__FILE__)}/../views"

  def reset_password_link(user)
    @subject    = "[#{Typus::Configuration.options[:app_name]}] #{_("Reset password")}"
    @body       = { :user => user }
    @recipients = user.email
    @from       = Typus::Configuration.options[:email]
    @sent_on    = Time.now
    @headers    = {}
  end

end