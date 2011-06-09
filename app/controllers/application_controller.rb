# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper :all # include all helpers, all the time
  before_filter :login_required
  before_filter :find_project
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  layout "main.html.haml"

  helper_method :current_user_session, :current_user, :logged_in?

  protected
  
  def find_project
    @project = Project.find_by_id(params[:project_id]) || Project.first
  end

  
  private
    def login_required
      redirect_to new_user_sessions_url unless logged_in?
      logged_in?
    end
  
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    def logged_in?
      !current_user.nil?
    end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
