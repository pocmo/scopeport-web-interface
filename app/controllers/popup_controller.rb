require 'json'
require 'digest/sha1'

class PopupController < ApplicationController
  
  # get all popups to show
  def getpopups
    session[:popups] = [] if session[:popups].blank?
    timestamp = params[:timestamp].to_i == 0 ? session[:login_at].to_i : params[:timestamp]
    
    popups = []
    
    popups = popups | getServiceAlarmPopups(timestamp) | getHostAlarmPopups(timestamp)
    
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
      :conditions => ["timestamp >= ? AND alarm_type = 2 AND services.name != ''", timestamp],
      :select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, services.name AS servicename, alarms.service_state",
      :joins => "LEFT JOIN services ON services.id = alarms.service_id"
    
    alarms.each do |alarm|
      id = Digest::SHA1.hexdigest(alarm.id.to_s + '|alarm|' + alarm.timestamp.to_s);
      alarm.servicename = "?" if alarm.servicename.nil?
      if ! session[:popups].include? id
        popups.push({
          "id"     => id,
          "title"  => "Alarm (" + alarm.servicename + ")",
          "text"   => getServiceAlarmMessage(alarm.service_state, alarm.ms) + ' <a href="' + url_for(:controller => 'alarms', :action => "showservicealarm", :id => alarm.id) + '">Details</a>',
          "sticky" => true,
          "image"  => "/images/icons/alarm.png"
        })
      end
    end
    
    return popups
  end
  
  
  def getHostAlarmPopups timestamp
    popups = []
    
    alarms = Alarm.find :all,
      :conditions => ["timestamp >= ? AND alarm_type = 1 AND hosts.name != ''", timestamp],
      :select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, alarms.sensor, alarms.value, hosts.name AS hostname",
      :joins => "LEFT JOIN hosts ON hosts.id = alarms.host_id"

    alarms.each do |alarm|
      id = Digest::SHA1.hexdigest(alarm.id.to_s + '|alarm|' + alarm.timestamp.to_s);
      if ! session[:alarm].include? id
        popups.push({
          "id"     => id,
          "title"  => "Alarm (" + alarm.hostname + ")",
          "text"   => getHostAlarmMessage(alarm.sensor, alarm.value) + ' <a href="' + url_for(:controller => 'alarms', :action => "showhostalarm", :id => alarm.id) + '">Details</a>',
          "sticky" => true,
          "image"  => "/images/icons/alarm.png"
        })
      end
    end
    
    return popups
  end
  
end
