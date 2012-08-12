#
# LEVEL EXPECTATIONS
#


# Events - an array of events, their numerical values, datetime
# Display --> scales the display based on
# 

class Happening
	attr_accessor :value, :datetime, :name, :description
	
	def initialize(value, name, description)
		@value = value
		@name = name
		@description = description
		@datetime = DateTime.now
	end
end


Shoes.app :width => 1000 do

	@happenings = []
	
	def refresh_messages
		@total = 0
		@messages.clear do
			@happenings.each do | happs |
				t = happs.datetime.strftime("On %m/%d/%Y added at %I:%M%p")
				para t + " " + happs.value.to_s + " " + happs.name.to_s + " " + happs.description.to_s
				@total += happs.value.to_i
			end
			para "total " + @total.to_s
		end
	end
	
	def refresh_display
		@display.clear do
			background "#FFF"
			# set a constant based on elapsed seconds and canvas width
			@start_time = @happenings.first.datetime
			@end_time = @happenings.last.datetime
			@elapsed_seconds = ( ( @end_time - @start_time ) * 24 * 60 * 60 ).to_i
			@move_x = ( 1000 / @elapsed_seconds )
			
			@running_total = 0
			
			# for each event
			@happenings.each do | happs |
				# add the value to the running total
				@running_total += happs.value.to_i
				# set x as elapsed seconds * constant x, y as running total
				@draw_x = ( ( ( happs.datetime - @start_time ) * 24 * 60 * 60 ) * @move_x )
				@draw_y = 300-@running_total
				#draw a point
				if @running_total > 0
					fill green
				elsif @running_total < 0
					fill red
				else
					fill black
				end
				oval @draw_x, @draw_y, 10
				# draw a line from the last point to the new point
				    # TO DO
			end
		para "Total Good Feeling " + @running_total.to_s
		end
	end
	
	subtitle "Level Expectations"
	
	@messages = stack :width => 400 do
		para @happenings
	end
	
	@display = stack :width => 1000, :height => 400 do
		background "#FFF"
	end
	
	@add_form = flow :width => 500 do
		para "name"
		@name = edit_line
		para "description"
		@description = edit_box
		para "value"
		@value = edit_line
		button "Add" do
			@new = Happening.new(@value.text, @name.text, @description.text)
			@happenings << @new
			#refresh_messages
			refresh_display
			#compare_events
		end
	end
	
	@comparison = stack do
		para "So that last event is similar to ... "
	end

end