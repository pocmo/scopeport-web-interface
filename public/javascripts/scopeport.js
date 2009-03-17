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
