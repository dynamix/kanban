class LivelogsController < ApplicationController
    
  def show
    @livelog = @project.livelog
  end
  
end