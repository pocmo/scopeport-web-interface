// framebuster (against clickjacking)
if (top != self) {
	self.document.location = 'about:blank';
}

window.onload = function(){
  var rows = document.getElementsByTagName("tr");
  for(var i=0,l=rows.length;i<l;i++){
    row = rows[i];
    if(row.className != "sensor-error" && row.className != "sensor-okay" && row.className != "sensor-none" && row.className != "sensor-warn" && row.className != "sensor-internal-error" || !row.className){
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

function toggleCheckboxValue(el){
  if(el.value == "0"){
    el.checked = true;
    el.value = "1";
    return;
  }

  if(el.value == "1"){
    el.checked = false;
    el.value = "0";
    return;
  }
}

function disableOtherReceiverFields(thisfield){
  var fields = new Array( document.getElementById("newGroup_mail"),
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

function hideComment(id){
  comment = document.getElementById("comment_" + id);
  comment.style.display = "none";
}

function updateAlarmRow(status, alarmid, el){
    row = el.parentNode.parentNode;
    statuscol = document.getElementById("alarm-status-" + alarmid);
    checkbox = el;

    if(status == "true"){
      statuscol.innerHTML = "New/Unattended";
      row.style.backgroundColor= "#F8F8F8";
      row.style.backgroundImage= "url(../images/errorbg-blink.gif)";
    }else{
      statuscol.innerHTML = "Okay/Attended <strong>(me)</strong>";
      row.style.backgroundColor= "#91FF74";
      row.style.backgroundImage= "url()";
    }
    checkbox.disabled = true;
}

function showAlarmFilterOptions(link){
  link.style.display = "none";
  $("alarms-service-filters").appear();
}

function clearFiltersForm() {
	elements = $('filters_form').getElements();
	for(i = 1; i < 8; i++) {
		if(elements[i].name == "time") {
			elements[i].value = ""
		}else if(elements[i].name == "time_unit") {
		//Do nothing...
		} else { 
		elements[i].value = "Any"
		}
	}

}

//TODO Improve
function updateForm (fields) {
	cf = eval("(" + fields + ")");
	if (cf == null) {
		clearFiltersForm();
	} else {	elements = $('filters_form').getElements();
			elements[1].value = cf.by_attendee;	
			elements[2].value = cf.from_service;
			elements[3].value = cf.service_group;
			elements[4].value = cf.time_ago;
			elements[5].value = cf.time_unit;
			elements[6].value = cf.status;
			elements[7].value = cf.service_state;
	}
}

function bigRedButtonSlide(){
  document.getElementById('bigredbutton').style.display = "";
  document.getElementById('bigredbutton-activator').style.display = "none";
  Effect.Pulsate('bigredbutton-pulse', { pulses: 9999, duration: 9999 });
}

function appendToList(x){
  var container = document.getElementById("emergency-chat-list");
  var newElement = document.createElement("li");
  newElement.innerHTML = x;
  container.insertBefore(newElement, container.lastChild);
}

function scrollToBottom(x){
  var scroll = document.getElementById("autoscroll");
  if(scroll.checked){
    var el = document.getElementById(x);
    el.scrollTop = el.scrollHeight;
  }
}

function scaleChatField(){
  field = document.getElementById("emergency-chat-list");
  link = document.getElementById("emergency-chat-grower");
  if(link.innerHTML == "More"){
    field.style.height = "500px";
    link.innerHTML = "Less"
  }else{
    field.style.height = "150px";
    link.innerHTML = "More"
  }
}

function clearSearch(){
  jQuery('#suggestions').fadeOut();
}

function search(inputString, token) {
  if(inputString.length == 0) {
    jQuery('#suggestions').fadeOut(); // Hide suggestions
  }else{
    jQuery.post("/search/showresults", {query_string: ""+inputString+"", authenticity_token: token}, function(data) { // AJAX call
    jQuery('#suggestions').fadeIn(); // Show suggestions
    jQuery('#suggestions').html(data); // Fill suggestions
    });
  }
}

function showNics(){
	jQuery('#hosts-host-nics').fadeIn();
	jQuery('#hosts-host-show-nics').fadeOut();
}

function showCpus(){
	jQuery('#hosts-host-cpus').fadeIn();
	jQuery('#hosts-host-show-cpus').fadeOut();
}

function showGraph(name, hostId, token){
  // Remove blurred graph.
  loading = document.getElementById("graph-" + name + "-blurred");
  loading.style.display = "none";

  // Show loading symbol.
  loading = document.getElementById("graph-" + name + "-loading");
  loading.style.display = "";

  // Load graph.
  new Ajax.Updater('hosts-host-graph-' + name, '/hosts/show_graph_' + name + '/' + hostId, {asynchronous:true, evalScripts:true, parameters:'authenticity_token=' + encodeURIComponent(token)})
}
