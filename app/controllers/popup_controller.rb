require 'json'

class PopupController < ApplicationController
  
  def getpopups
    popups = []
    
    popups = popups | getServiceAlarmPopups
    
    render :text => popups.to_json
  end
  
  private
  
  def getServiceAlarmPopups
    popups = []
    
    alarms = Alarm.find :all,
      :conditions => ["timestamp >= ?", params[:timestamp]],
      :select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, services.name AS servicename, alarms.service_state",
      :joins => "LEFT JOIN services ON services.id = alarms.service_id"
    
    alarms.each do |alarm|
      popup = {
        "title"  => "Alarm (" + alarm.servicename + ")",
        "text"   => getServiceAlarmMessage(alarm.service_state, alarm.ms),
        "sticky" => true,
        "image"  => "/images/icons/alarm.png"
      }
      popups.push popup
    end
    
    return popups
  end
  
end
