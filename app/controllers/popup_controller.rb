require 'json'
require 'digest/sha1'

class PopupController < ApplicationController
  
  def getpopups
    session[:popups] = [] if session[:popups].blank?
    timestamp = params[:timestamp].to_i == 0 ? session[:login_at].to_i : params[:timestamp]
    
    popups = []
    
    popups = popups | getServiceAlarmPopups(timestamp)
    
    render :text => popups.to_json
  end
  
  def closepopup
    session[:popups].push params[:id]
    render :text => ""
  end
  
  private
  
  def getServiceAlarmPopups timestamp
    popups = []
    
    alarms = Alarm.find :all,
      :conditions => ["timestamp >= ?", timestamp],
      :select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, services.name AS servicename, alarms.service_state",
      :joins => "LEFT JOIN services ON services.id = alarms.service_id"
    
    alarms.each do |alarm|
      id = Digest::SHA1.hexdigest(alarm.id.to_s + '|alarm|' + alarm.timestamp.to_s);
      alarm.servicename = "?" if alarm.servicename.nil?
      if ! session[:popups].include? id
        popup = {
          "id"     => id,
          "title"  => "Alarm (" + alarm.servicename + ")",
          "text"   => getServiceAlarmMessage(alarm.service_state, alarm.ms),
          "sticky" => true,
          "image"  => "/images/icons/alarm.png"
        }
        popups.push popup
      end
    end
    
    return popups
  end
  
end
