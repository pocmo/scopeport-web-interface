window.onload = function(){
	// Fetch every input field.  
  var inputs = document.getElementsByTagName("input");

	// Go through every input field.  
  for(i=0,l=inputs.length;i<l;i++){

		// Get the current field.  
    field = inputs[i];
		
		// Skipt if this field is not needed.  
		if(field.name == "authenticity_token" || field.name == "commit")
			continue;
		
		field.onfocus = function(){
			// Position of start to substring.  
			start = this.name.indexOf("[")+1;

			// Get the name out of the field. e.g. "service[name]" gets "name"
			fieldname = this.name.substr(start, this.name.length-start-1);

			// Get the element we want to change the class of.
    	helptext = document.getElementById("formhelp-" + fieldname);
			if(helptext)
				helptext.className = "formhelp-highlighted";
    }

		field.onblur = function(){
			// Position of start to substring.  
			start = this.name.indexOf("[")+1;

			// Get the name out of the field. e.g. "service[name]" gets "name"
			fieldname = this.name.substr(start, this.name.length-start-1);

			// Get the element we want to change the class of.
    	helptext = document.getElementById("formhelp-" + fieldname);
			if(helptext)
				helptext.className = "formhelp-normal";
    }
  }

	// Fetch every select field.  
  var selects = document.getElementsByTagName("select");
	
	// Go through every form field.  
  for(i=0,l=selects.length;i<l;i++){

		// Get the current field.  
    field = selects[i];
		
		// Skipt if this field is not needed.  
		if(field.name == "authenticity_token" || field.name == "commit")
			continue;
		
		field.onfocus = function(){
			// Position of start to substring.  
			start = this.name.indexOf("[")+1;

			// Get the name out of the field. e.g. "service[name]" gets "name"
			fieldname = this.name.substr(start, this.name.length-start-1);

			// Get the element we want to change the class of.
			helptext = document.getElementById("formhelp-" + fieldname);
			if(helptext)
				helptext.className = "formhelp-highlighted";
    }
    
		field.onblur = function(){
			// Position of start to substring.  
			start = this.name.indexOf("[")+1;

			// Get the name out of the field. e.g. "service[name]" gets "name"
			fieldname = this.name.substr(start, this.name.length-start-1);

			// Get the element we want to change the class of.
    	helptext = document.getElementById("formhelp-" + fieldname);
			if(helptext)
				helptext.className = "formhelp-normal";
		}
	}
};

function triggerOtherFormFields(caller){
	// Fetch every input field.  
  var inputs = document.getElementsByTagName("input");

	// Go through every input field.  
  for(i=0,l=inputs.length;i<l;i++){
		// Get the current field.  
    field = inputs[i];

    if(field != caller && field.id != "submit" && field.name != "authenticity_token"){
      if(field.disabled == 0){
        field.disabled = 1;
      }else{
        field.disabled = 0;
      }
    }

  } 
}

function updateForm (fields) {
	//Do something...
}
