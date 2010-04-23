class StatisticsController < ApplicationController

  # per user
  #  items in progress (unique)
  #  items in to test (unique)
  #  average time in progress
  #  average time in to test
  # per column average time
  # average WIP time
  def index
    users = User.all
    @user_stats = {}
    users.each do |user|
      @user_stats[user.id] = {}
      @user_stats[user.id][:user] = user
      @user_stats[user.id][:in_progress_count] = user.statistics.count(:all, :conditions => {:lane_id => Lane.progress_lane_id})
      @user_stats[user.id][:in_progress_unique_count] = user.statistics.count(:all, :conditions => {:lane_id => Lane.progress_lane_id}, :group => "item_id").length
      @user_stats[user.id][:to_test_count] = user.statistics.count(:all, :conditions => {:lane_id => Lane.test_lane_id})
      @user_stats[user.id][:to_test_unique_count] = user.statistics.count(:all, :conditions => {:lane_id => Lane.test_lane_id}, :group => "item_id").length
      @user_stats[user.id][:in_progress_average] = user.statistics.average(:duration, :conditions => {:lane_id => Lane.progress_lane_id})
      @user_stats[user.id][:in_progress_unique_average] = @user_stats[user.id][:in_progress_unique_count] > 0 ? ((user.statistics.sum(:duration, :conditions => {:lane_id => Lane.progress_lane_id})) / @user_stats[user.id][:in_progress_unique_count]) : 0
      @user_stats[user.id][:to_test_average] = user.statistics.average(:duration, :conditions => {:lane_id => Lane.test_lane_id})
      @user_stats[user.id][:to_test_unique_average] = @user_stats[user.id][:to_test_unique_count] > 0 ? ((user.statistics.sum(:duration, :conditions => {:lane_id => Lane.test_lane_id})) / @user_stats[user.id][:to_test_unique_count]) : 0
    end
    lanes = Lane.all
    @lane_stats = {}
    lanes.each do |lane|
      @lane_stats[lane.title] = lane.statistics.average(:duration)
    end
    wip_sums = Statistic.sum(:duration, :group => "item_id", :conditions => ["lane_id NOT IN (?)", Lane.ids_not_wip_relevant]).map{|k, v| v}.compact
    wip_num = wip_sums.length
    wip_sum = wip_sums.inject(0){|b,i| b+i}
    @average_wip = wip_num == 0 ? 0 : (wip_sum / wip_num)
  end
end


