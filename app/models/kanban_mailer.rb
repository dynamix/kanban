class KanbanMailer < ActionMailer::Base

  def login_info(name,email, password,url)
    subject     'Login-Info to the kanban-tool'
    recipients  [email]
    from        'info@kanbantool'
    body        :name => name,
                :email =>email,
                :password=>password,
                :url=>url
  end  

end
