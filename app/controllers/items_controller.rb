class ItemsController < ApplicationController
  
  before_filter :find_lane
  
  def edit
    @item = @lane.items.find_by_id(params[:id])
    return render(:partial => 'item_overlay', :locals => {:url => item_path(@project, @lane, @item), :method => :put})
  end
  
  def update
    
  end
  
  def create
    @item = Item.new(params[:item])
    @item.owner = current_user
    @item.lane = @lane
    @item.save
    @lane.items.last.move_to_top
    return render(:partial => 'item', :locals => {:lane => @lane}, :object => @item)
  end
  
  def dnd
    @item = Item.find_by_id(params[:id])
    @target_lane = Lane.find_by_id(params[:target_lane_id])
    @item.remove_from_list
    @item.lane = @target_lane
    @item.insert_at(params[:index])
    return render(:nothing => true)
  end
  
  protected
  def find_lane
    @lane = @project.lanes.find_by_id(params[:lane_id])
  end
  
end