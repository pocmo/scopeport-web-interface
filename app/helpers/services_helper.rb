module ServicesHelper

	#Is there a new comment in the last 24 hours (default) ?
	def new_comment?(service, time = 24.hour.ago)
		!service.servicecomments.recent(time).empty?
	end
	
	#If there's a new comment, returns a image
	def new_comment_mark
		showIcon("comment", "margin-left: 3px;")
	end

end
