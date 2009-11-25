class SensorconditionsController <ApplicationController
  def change
    @host = Host.find params[:id]
    @conditions = Hash.new

    sensors = Host::getSensors
    sensors.each do |sensor|
      @conditions[sensor] = Hash.new
      @conditions[sensor]["condition"] = Sensorcondition.find_by_host_id_and_sensor @host, sensor
      recent = Recentsensorvalue.find_by_host_id_and_name @host, Host::shortToLongSensorName(sensor)
      if recent.blank? or recent.value.blank?
        @conditions[sensor]["last_value"] = nil
      else
        @conditions[sensor]["last_value"] = recent.value
      end
    end
  end

  def update
    host = Host.find params[:id]
    redirect_to :controller => "overview" if params[:id].blank? or host.blank?
    if params[:conditions].blank? or params[:operators].blank?
      flash[:error] = "Could not save conditions: Missing parameters."
      redirect_to :action => "update", :id => params[:id]
    end

    # We got all needed parameters
    params[:conditions].each do |name, condition|
      # Is a valid operator set?
      next if params[:operators][name].blank? or !validOperator? params[:operators][name] or name.blank? or condition.blank? 
      
      # Does the condition already exist?
      cd = Sensorcondition.find_by_host_id_and_sensor params[:id], name
      cd = Sensorcondition.new if cd.blank?
      cd.host_id = params[:id]
      cd.sensor = name
      cd.operator = params[:operators][name]
      cd.value = condition
      cd.save
    end
    flash[:notice] = "The conditions have been saved"
    log("changed", "sensor conditions", [host.name, host.id])
    redirect_to :action => "change", :id => params[:id]
  end

  private

  def validOperator? operator
    return true if operator == "<"
    return true if operator == ">"
    return true if operator == "="
    return false
  end

end
