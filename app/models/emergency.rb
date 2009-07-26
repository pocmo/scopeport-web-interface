class Emergency < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :severity

  belongs_to :user
  has_many :emergencychatmessages
  has_many :emergencycomments, :order => "created_at DESC"
end
