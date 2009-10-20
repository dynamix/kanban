class ItemsController < ApplicationController
  
  before_filter :find_lane
  
  def edit
    @item = @lane.items.find_by_id(params[:id])
    return render(:partial => 'item_overlay', :locals => {:url => item_path(@project, @lane, @item), :method => :put})
  end
  
  def update
    @item = @lane.items.find_by_id(params[:id])
    @item.owner_id = params[:item][:owner_id]
    @item.title = params[:item][:title]
    @item.text = params[:item][:text]
    @item.estimation = params[:item][:estimation]
    @item.last_editor=current_user
    @item.save
    return render(:partial => 'item_content', :locals => {:item => @item})
  end
  
  def create
    @item = Item.new(params[:item])
    @item.last_editor = current_user
    # @item.owner = current_user
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
    @item.last_editor = current_user
    @item.insert_at(params[:index])
    return render(:partial => 'item_content', :locals => {:item => @item})
  end
  
  protected
  def find_lane
    @lane = @project.lanes.find_by_id(params[:lane_id])
  end
  
end