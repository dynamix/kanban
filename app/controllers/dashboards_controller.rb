class DashboardsController < ApplicationController

  
  def show
    @standard_lanes = @project.lanes.standard
    @parking_lane = @project.parking
  end
  
end