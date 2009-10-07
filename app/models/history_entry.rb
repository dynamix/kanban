class HistoryEntry < ActiveRecord::Base
  belongs_to :item
  belongs_to :trigger, :polymorphic => true
end