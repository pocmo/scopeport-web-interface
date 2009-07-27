class Emergency < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :severity

  belongs_to :user
  has_many :emergencychatmessages
  has_many :emergencycomments, :order => "created_at DESC"
  has_many :emergencychatusers
	
  def active_users
    return emergencychatusers.active(30.seconds.ago).count
	end

  def all_active_chat_users
    return emergencychatusers.active 30.seconds.ago
  end
end
