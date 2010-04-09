class Item < ActiveRecord::Base
  # vestal_versions plugin
  # http://github.com/laserlemon/vestal_versions
  versioned
  
  has_many :history_entries
  belongs_to :lane
  belongs_to :owner, :class_name => 'User'
  belongs_to :last_editor, :class_name => 'User'

  acts_as_list :scope => :lane

  before_save :update_time_counters
  after_save :update_statistics


  WIP_TOTAL_WARN = 3600*24*10 # 10 days
  WIP_TOTAL_URGENT = 3600*24*20 # 20 days

  # possible states are :normal, :warn, :urgent
  def todo_state
    return :normal if !self.wip_total
    return :urgent if self.wip_total > WIP_TOTAL_URGENT
    return :warn if self.wip_total > WIP_TOTAL_WARN

    return :normal if !self.lane
    return :urgent if self.lane.urgent_limit and self.wip_current > self.lane.urgent_limit
    return :warn if self.lane.warn_limit and  self.wip_current > self.lane.warn_limit
    return :normal
  end
  
  def wip_current
    return 0 if !self.current_lane_entry
    return (Time.now - self.current_lane_entry)
  end
  
  def update_statistics
    unless changed? and !changes["lane_id"].nil?
      Statistic.create(:lane => self.lane, :user => self.owner, :item => self, :entry_time => Time.now) if self.new_record? && self.lane
      if !self.new_record? && !changes["owner_id"].nil?
        stat = Statistic.find(:first, :order => 'id DESC', :conditions => {:lane_id => self.lane, :item_id => self})
        stat.update_attribute(:user_id, changes["owner_id"][1]) if stat
      end
      return  
    end
    old_lane_id,new_lane_id = changes["lane_id"]
    
    old_lane = old_lane_id.to_lane if old_lane_id
    new_lane =  new_lane_id.to_lane if new_lane_id
    if old_lane
      stat = Statistic.find(:first, :order => 'id DESC', :conditions => {:lane_id => old_lane, :item_id => self})
      stat.update_attribute(:leave_time, Time.now) if stat
    end
    Statistic.create(:lane => new_lane, :user => self.owner, :item => self, :entry_time => Time.now) if new_lane
  end
  
  # wip counters - needed to determine the current and the overall WIP
  # wip_current - for the current lane
  # wip_total - for all lanes
  def update_time_counters
    unless changed? and !changes["lane_id"].nil?
      self.current_lane_entry = Time.now if self.new_record? && self.lane && self.lane.counts_wip
      return  
    end
    old_lane_id,new_lane_id = changes["lane_id"]
    
    old_lane = old_lane_id.to_lane if old_lane_id
    new_lane =  new_lane_id.to_lane if new_lane_id

    # add the time spent in the old_lane to the wip_total
    if old_lane and  current_lane_entry #and old_lane.counts_wip # not_needed?
      self.wip_total ||= 0
      self.wip_total += (Time.now - self.current_lane_entry)
      self.current_lane_entry=nil      
    end
    # start new counter for the new lane, if needed
    if new_lane and new_lane.counts_wip
      self.current_lane_entry=Time.now
    end
  end
end