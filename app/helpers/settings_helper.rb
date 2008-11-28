module SettingsHelper
  
  def friendly_nil(object)
    
    if object == nil
      return ''
    else
      object.to_s
    end
  end
  
  
end
