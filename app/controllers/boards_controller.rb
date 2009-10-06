class BoardsController < ApplicationController
  
  before_filter :load_stories, :only=>:show
  def show
    
  end
  
  protected 
  def load_stories
    @states_with_stories = Story::STATES.map do |state|
      state[:stories]=Story.by_state(state[:name])
      state
    end
  end
end
