window.onload = function(){
  var rows = document.getElementsByTagName("tr");
  for(var i=0,l=rows.length;i<l;i++){
    row = rows[i];
    if(row.className != "sensor-error" && row.className != "sensor-okay" && row.className != "sensor-none" && row.className != "sensor-warn" || !row.className){
      if(row.className != "doNotHighlightMe"){
        row.onmouseover = function(){
            this.className = "rowHighlighted";
         }
        row.onmouseout = function(){
            this.className = "rowNotHighlighted";
         }
      }
    }
  }
};
 
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
			if(helptext != null)
				helptext.className = "formhelp-highlighted";
    }

		field.onblur = function(){
			// Position of start to substring.  
			start = this.name.indexOf("[")+1;

			// Get the name out of the field. e.g. "service[name]" gets "name"
			fieldname = this.name.substr(start, this.name.length-start-1);

			// Get the element we want to change the class of.
    	helptext = document.getElementById("formhelp-" + fieldname);
			if(helptext != null)
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
			if(helptext != null)
				helptext.className = "formhelp-highlighted";
    }
    

		field.onblur = function(){
			// Position of start to substring.  
			start = this.name.indexOf("[")+1;

			// Get the name out of the field. e.g. "service[name]" gets "name"
			fieldname = this.name.substr(start, this.name.length-start-1);

			// Get the element we want to change the class of.
    	helptext = document.getElementById("formhelp-" + fieldname);
			if(helptext != null);
				helptext.className = "formhelp-normal";
		}
	}
};

function disableOtherReceiverFields(thisfield){
  var fields = new Array(  document.getElementById("newGroup_mail"),
                          document.getElementById("newGroup_jid"),
                          document.getElementById("newGroup_numberc"));
  thisfieldName = "newGroup[" + thisfield + "]";
  for(var i = 0,l=fields.length;i<l;i++){
    field = fields[i];
    if(field.name != thisfieldName){
      field.value = "";
      field.disabled = true;
    }
  }
}
 
function clearFieldWithText(field, standardtext){
  if(field.value == standardtext)
    field.value = "";
}
