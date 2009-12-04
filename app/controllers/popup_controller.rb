class PopupController < ApplicationController
  def getalarms
    alarms = Alarm.find :all,
      :conditions => ["timestamp >= ?", params[:timestamp]],
      :select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, services.name AS servicename, alarms.service_state",
      :joins => "LEFT JOIN services ON services.id = alarms.service_id"
    render :json => alarms.to_json
  end
end
