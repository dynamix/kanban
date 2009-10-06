class Story < ActiveRecord::Base
  STATES=[
      {:name=>:todo, :wip_limit=>0}, #wip_limitt=>0 means: no limit
      {:name=>:develop, :wip_limit=>2},
      {:name=>:deploy_staging, :wip_limit=>2},      
      {:name=>:test,   :wip_limit=>2},
      {:name=>:deploy_live, :wip_limit=>2},
      {:name=>:live, :wip_limit=>0}  
    ]
    
    # named_scope :by_state_or_all, lambda { |state| state.nil? ? {} : { :conditions => { :state => state.to_s} }}
    named_scope :by_state, lambda { |state| { :conditions => { :state => state.to_s} }}
end