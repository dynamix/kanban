class DashboardsController < ApplicationController

  
  def show
    @restricted_lanes = @project.lanes.restricted
    @parking_lane = @project.parking
  end
  
end