class CommentsController < ApplicationController
    
  def index
    @comments = Comment.for_item(params[:item_id])
    if request.xhr?
      render :partial => 'comment_list'
    else
      render :index
    end
  end
  
  def new
    require 'ruby-debug'
    debugger
    puts "Debug"
    if request.xhr?
      render :partial => 'comment_added'
    end
  end
end