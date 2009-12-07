(function($) {
	var timeout = 10000;
	var timestamp = Math.round(new Date().getTime() / 1000);
	check = function() {
		$.getJSON('/popup/getpopups', { 'timestamp': timestamp }, function(data, textStatus) {
			for (i = 0; i < data.size(); i++) {
				$.gritter.add(data[i]);
			}
		});
		timestamp = Math.round(new Date().getTime() / 1000);
		setTimeout(check, timeout);
	}
	check();
})(jQuery);
