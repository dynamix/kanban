class DashboardsController < ApplicationController

  
  def show
    @standard_lanes = @project.lanes.standard
  end
  
end