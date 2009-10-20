class DashboardsController < ApplicationController
  
  def show
    @lanes = @project.lanes.top_level.on_dashboard
  end
  
end