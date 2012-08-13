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


Shoes.app :width => 1000, :height => 660 do

	@happenings = [ Happening.new(0,"nothing","initial") ]
	
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
			@ovals = []
			background "#FFF"
			line 0, 305, 1000, 305
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
				@o = oval @draw_x, @draw_y, 10
				@ovals << @o
				# draw a line from the last point to the new point
				    # TO DO
				@ovals.each_with_index do |o,ind|
					o.hover do
					 @inspector.clear do
	  				 background "#FF6"
		  			 para "name: " + @happenings[ind].name.to_s + " val: " + @happenings[ind].value.to_s
					 end
					end
				end
				
			end
		para "Total Good Feeling " + @running_total.to_s
		end
	end
	
	# Compares last input event to similar-value events in @happenings, and prints
	def compare_events
		
		@message = "at least it changed"
		@values = []
		@equal_values = []
		@equal_indices = []
		@entered_value = @value.text.to_i
		@random_name = ""
		
		# search in array for value = last entered value
		def search
		@happenings.each do | happs |
			@entered_value = @value.text.to_i
			@array_value = happs.value
			if @entered_value == @array_value
				return "Exactly the same as #{ happs.name.to_s }"
			# if the value is 5 more or 5 less
			elsif @array_value === ( ( @entered_value - 5 )..( @entered_value + 5 ) )
				# similar to
				return "Similar to #{ happs.name.to_s }"
			# if there's no such value, and entered value is positive, look for another positive value,
			elsif @entered_value > 0 and @array_value > 0
				@times = @entered_value / @array_value
				return "This event is #{ @times } times better than @{ happs.name.to_s }"
			# if there's no such value, and entered value is negative, look for another negative
			elsif @entered_value < 0 and @array_value < 0
				# x times worse than
				@times = @entered_value / @array_value
				return "This event is #{ @times } times worse than @{ happs.name.to_s }"
			else
				return "An event beyond compare! Array: #{@array_value} Entered: #{@entered_value}"
			end
		end #array search
		end
		
		def better_search
			# make an array from just the array values
			
			# Find the indexes of all values that are equal to the entered value
			@happenings.each_with_index do | happs, index |
				if happs.value.to_i == @entered_value.to_i
					@equal_indices << index
				end
			end
			#return a random name from the set of equal values
			
			#change val to ind
			@random_val = @equal_indices[rand(@equal_indices.length-1)]
			@random_name = @happenings[@random_val].name.to_s
			
			if @equal_indices.length > 1
				return "A value of #{@entered_value} is as good/bad as \"#{@random_name}\"."
			elsif @equal_indices.length <= 1
				@random_val = rand(@happenings.length-1)
				@random_name = @happenings[@random_val].name.to_s
				@random_value = @happenings[@random_val].value.to_f
				@times = ( @entered_value / @random_value ).to_f.to_s
				return "This is #{@times} times as good as #{@random_name}"
			else
				return "An event beyond compare!"
			end
			#end
			# if none, find all that are in a range
			# if none and it's positive, find a positive and divide
			# if none and it's negative, find a negative and divide
			# if none, womp womp with reasons why
		end #better_search
		
		@comparison.clear do
			background "#6F6"
			para better_search
		end
	end #compare_events
	
	subtitle "Level Expectations"
	
	
	@save_panel = flow :width => 500 do
		button "Load" do
			File.open('happenings.txt','r') do |f|
				@happenings = Marshal::load(@serialized_object)
				refresh_display
			end
		end
		
		button "Save" do
			File.open('happenings.txt','w') do |f|
				@serialized_object = Marshal::dump( @happenings )
				f.puts @serialized_object
				refresh_display
			end
		end
		
		button "Erase & Start Afresh" do
			@happenings = [ Happening.new(0,"nothing","initial") ]
			refresh_display
		end
	end #flow of save panel
	
	
	
	@messages = stack :width => 400 do
		#para @happenings
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
			compare_events
			refresh_display
		end
	end
	
	@comparison = stack :width => 400 do
		background "#6F6"
		para "Comparisons to other events appear here."
	end
	
	@inspector = stack :width => 400 do
		background "#FF6"
		para "Inspector"
	end

end