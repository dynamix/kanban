class Statistic < ActiveRecord::Base
  belongs_to :lane
  belongs_to :item
  belongs_to :user
  
  before_save :calc_duration
  
  def calc_duration
    if entry_time && leave_time
      self.duration = self.leave_time - self.entry_time
    end
  end
end