class SensorconditionsController < ApplicationController
  def change
    @raw_conditions = Sensorcondition.find_all_by_host_id params[:id]
    @host = Host.find params[:id]

    @conditions = Hash.new
    @raw_conditions.each do |condition|
      @conditions[condition.sensor] = condition
      long_sensor_name = shortToLongSensorName(condition.sensor)
      if long_sensor_name.blank?
        @conditions[condition.sensor]["last_value"] = String.new
      else
        @last_value = Recentsensorvalue.find_by_host_id_and_name @host.id, shortToLongSensorName(condition.sensor)
        if @last_value.blank? or @last_value.value.blank?
          @conditions[condition.sensor]["last_value"] = String.new
        else
          @conditions[condition.sensor]["last_value"] = @last_value.value
        end
      end
    end
  end

  def update
    redirect_to :controller => "overview" if params[:id].blank?
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
