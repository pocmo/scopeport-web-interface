(function($) {
	var timeout = 10000;
	var timestamp = Math.round(new Date().getTime() / 1000);
	check = function() {
		$.getJSON('/popup/getalarms', { 'timestamp': timestamp }, function(data, textStatus) {
			timestamp = Math.round(new Date().getTime() / 1000);
			for (i = 0; i < data.size(); i++) {
				var alarm = data[i].alarm;
				var text = 'Unknown';
				if (alarm.service_state == 0) text = 'The service could not be reached';
				if (alarm.service_state == 2) text = 'The service had a too high response time (' + alarm.ms + ' ms)';
				if (alarm.service_state == 4) text = 'The service timed out';
				$.gritter.add({
					title: 'Alarm (' + alarm.servicename + ')',
					image: '/images/icons/alarm.png',
					text: text,
					sticky: true
				});
			}
		});
		setTimeout(check, timeout);
	}
	check();
})(jQuery);
