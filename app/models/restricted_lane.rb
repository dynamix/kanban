class RestrictedLane < Lane
  acts_as_list :scope => :super_lane
end