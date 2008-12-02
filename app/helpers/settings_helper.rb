module SettingsHelper
  
  def friendly_nil(object)
    
    if object === nil
      return ''
    elsif object === true 
      return "checked"     
    else
      object.to_s
    end
  end
  
  def label_txtfd_err(form, attr_key, label_description, object_attr, object)
    
      label_field = form.label(attr_key, label_description)
      text_field = form.text_field(attr_key, :value => friendly_nil(object_attr))
      error_field = error_message_on(object, attr_key)
      
      return "#{label_field}#{text_field}#{error_field}"
  end
  
end
