require 'json'
require 'digest/sha1'

class PopupController < ApplicationController
  
  # get all popups to show
  def getpopups
    session[:popups] = [] if session[:popups].blank?
    
    timestamp = params[:timestamp].to_i == 0 ? session[:login_at].to_i : params[:timestamp]
    
    popups = []
    
    popups = popups | get_service_alarm_popups(timestamp) | get_host_alarm_popups(timestamp) | get_temp_popups(timestamp)
    
    render :text => popups.to_json
  end
  
  
  def closepopup
    session[:popups].push params[:id]
    render :text => ""
  end
  
  
  private
  
  
  def get_service_alarm_popups timestamp
    popups = []
    
    alarms = Alarm.find :all,
      :conditions => ["timestamp >= ? AND alarm_type = 2 AND services.name != ''", timestamp],
      :select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, services.name AS servicename, alarms.service_state",
      :joins => "LEFT JOIN services ON services.id = alarms.service_id"
    
    alarms.each do |alarm|
      id = alarm.get_popup_id
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
  
  
  def get_host_alarm_popups timestamp
    popups = []
    
    alarms = Alarm.find :all,
      :conditions => ["timestamp >= ? AND alarm_type = 1 AND hosts.name != ''", timestamp],
      :select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, alarms.sensor, alarms.value, hosts.name AS hostname",
      :joins => "LEFT JOIN hosts ON hosts.id = alarms.host_id"

    alarms.each do |alarm|
      id = alarm.get_popup_id
      if ! session[:popups].include? id
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
  
  
  def get_temp_popups timestamp
    #session[:temporary_popups] = [] if session[:temporary_popups].blank?
    popups = []
    
    # only show temporary popups on first request of every "page"
    if timestamp.to_i == session[:login_at].to_i 
      session[:temporary_popups].each do |popup|
        if ! session[:popups].include? popup["id"]
          popups.push(popup)
        else
          session[:temporary_popups].delete popup
          session[:popups].delete popup["id"]
        end
      end
    end
    
    return popups
  end
  
end
