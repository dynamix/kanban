class ItemsController < ApplicationController
  
  before_filter :find_lane
  
  def create
    @item = Item.new(params[:item])
    @item.owner = current_user
    @item.lane = @lane
    @item.save
    return render(:partial => 'item', :object => @item)
  end
  
  protected
  def find_lane
    @lane = @project.lanes.find_by_id(params[:lane_id])
  end
  
end