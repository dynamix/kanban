class ItemsController < ApplicationController
  
  before_filter :find_lane
  
  def new
    @item = Item.new
    return render(:partial => 'item_overlay', :locals => {:url => project_lane_items_path(@project, @lane, @item), :method => :put})
  end
  
  def edit
    @item = @lane.items.find_by_id(params[:id])
    return render(:partial => 'item_overlay', :locals => {:url => project_lane_item_path(@project, @lane, @item), :method => :put})
  end
  
  def update
    @item = @lane.items.find_by_id(params[:id])
    @item.owner_id = params[:item][:owner_id]
    @item.title = params[:item][:title]
    @item.text = params[:item][:text]
    @item.estimation = params[:item][:estimation]
    @item.last_editor = current_user
    @item.size = params[:item][:size]
    @item.item_type = params[:item][:item_type]
    @item.save
    return render(:partial => 'item', :locals => {:item => @item})
  end
  
  def create
    if @lane.can_take_more_items?
      @item = Item.new(params[:item])
      @item.lane = @lane
      @item.save
      @lane.items.last.move_to_top
      return render(:partial => 'item', :locals => {:lane => @lane}, :object => @item)
    end
    return head(:ok)
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
  
  def destroy
    @item = Item.find_by_id(params[:id])
    @item.destroy if @item
    head(:ok)
  end                                  
  
  
  protected
  def find_lane
    @lane = @project.lanes.find_by_id(params[:lane_id])
  end
  
end