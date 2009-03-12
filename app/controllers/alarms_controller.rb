class AlarmsController < ApplicationController

	before_filter(:except => [:index, :showservicealarm, :attend, :unattend]) { |controller| controller.block unless controller.permission?}

	def index
		@service_alarms = Alarm.paginate :page => params[:page], :order => "alarms.timestamp DESC",
                                :conditions => "alarm_type = 2 AND services.name != ''",
																:select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, services.name AS servicename",
																:joins => "LEFT JOIN services ON services.id = alarms.serviceid"
  end

	def showservicealarm
		@alarm = Alarm.find(params[:id],
														:select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, services.name AS servicename",
														:joins => "LEFT JOIN services ON services.id = alarms.serviceid")

    if @alarm.servicename.blank?
      flash[:error] = "This alarm does not exist."
      redirect_to :controller => "alarms"
    end
	end

  def attend
    alarm = Alarm.find params[:id]

    if alarm.blank?
      flash[:error] = "This alarm does not exist."
      redirect_to :controller => "alarms"
      return
    end

    # Mark the alarm as "attended".
    alarm.status = 1

    if alarm.save
      flash[:notice] = "Status changed."
      redirect_to :action => "showservicealarm", :id => params[:id]
    else
      flash[:notice] = "Could not update status! Database error."
      redirect_to :action => "showservicealarm", :id => params[:id]
    end
  end

  def unattend
    alarm = Alarm.find params[:id]

    if alarm.blank?
      flash[:error] = "This alarm does not exist."
      redirect_to :controller => "alarms"
      return
    end

    # Mark the alarm as "attended".
    alarm.status = 0

    if alarm.save
      flash[:notice] = "Status changed."
      redirect_to :action => "showservicealarm", :id => params[:id]
    else
      flash[:notice] = "Could not update status! Database error."
      redirect_to :action => "showservicealarm", :id => params[:id]
    end
  end

end
