class UserSessionsController < ApplicationController
  skip_before_filter :login_required
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    # We are saving with a block to accomodate for OpenID authentication
    # If you are not using OpenID you can save without a block:
    #
    #   if @user_session.save
    #     # ... successful login
    #   else
    #     # ... unsuccessful login
    #   end
    @user_session.save do |result|
      if result
        user = User.find_by_email(@user_session.email)
        return redirect_to backlog_url(:project_id => Project.first.id)
      else
        render 'new'
      end
    end
  end
  
  def destroy
    current_user_session.destroy
    redirect_to '/'
    # redirect_back_or_default new_user_session_url
  end
end
