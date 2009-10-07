class BacklogsController < ApplicationController
    
  def show
    @backlog = @project.backlog
    @selected_lane = @project.lanes.find_by_title 'Selected'
    @item = Item.new
  end
  

  
end