class AlarmsController < ApplicationController
	def index
		@service_alarms = Alarm.paginate :page => params[:page], :order => "alarms.timestamp DESC", :conditions => "alarm_type = 2",
																:select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, services.name AS servicename",
																:joins => "LEFT JOIN services ON services.id = alarms.serviceid"
	end

	def showservicealarm
		@alarm = Alarm.find(params[:id],
														:select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, services.name AS servicename",
														:joins => "LEFT JOIN services ON services.id = alarms.serviceid")
	end
end
