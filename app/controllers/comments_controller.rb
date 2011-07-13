class CommentsController < ApplicationController
  before_filter :find_item
  
  def index
    @comments = Comment.for_item(params[:item_id])
    if request.xhr?
      render :partial => 'comment_list'
    else
      render :index
    end
  end
  
  def create
    if request.xhr?
      @comment = Comment.new(params[:comment])
      @comment.item = @item
      @comment.user = current_user
      
      if @comment.save
        return head 200
      else
        return head(400)
      end
    end
  end
  
  protected
  def find_item
    @item = Item.find_by_id(params[:item_id])
  end
end