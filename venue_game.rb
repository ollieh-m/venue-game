class Venue

attr_accessor(:capacity,:budget,:bookings,:cleanliness,:stock)

	def initialize capacity, budget
		@capacity = capacity
		@budget = budget
		@starting_budget = budget
		@bookings = []
		@cleanliness = 100
		@stock = {	'Beer' => 0,
					'Wine' => 0,
					'Juice' => 0}
		#each band has a name [0], a messiness score [1] showing how much less clean the venue is once they've played,
		#a consumption array [2], which determines what proportion of attendees drink a bottle of beer, a glass of wine and a cup of juice,
		#a quality score [3] determining how full the venue is, and a price [4]
		@bands = [	['Back Story',25,[100,75,50],50,1000],
					['The 1975',50,[200,100,25],100,5000],
					['The Beatles',30,[90,90,150],75,10000],
					['Fleetwood Mac',35,[80,80,50],100,7500],
					['The Unknowns',90,[200,200,30],25,100],
					['Fleet Foxes',20,[50,50,200],50,200],
					['Blondie',80,[100,100,40],90,2000],
					['Take That',30,[60,60,100],70,3000],
					['Local Band',70,[100,100,10],40,100]  ]
		@warning = 0
		@activities = 0
	end

#method for determining when the week has run out

def activities_check
	if @activities == 4
		puts "Aha, it\'s show time! Ready or not..."
		event
		@activities = 0
	end
end

#methods for helping the booking process

def valid_band?(band)
	valid_band = []
	@bands.each do |x|
		if x[0] == band
			valid_band.push(x)
		end
	end
	not valid_band.empty?
end


def band_options
	@bands.each do |x|
		unless @bookings.include?(x[0])
			puts "#{x[0]}, yours for £#{x[4]}."
		end
	end
end

def available_band?(band)
	options = []
	@bands.each do |x|
		unless @bookings.include?(x[0])
			options.push(x[0])
		end
	end
	options.any?{ |x| x.downcase==band.downcase }
end

def week_booked?(week)
	calendar = ['this week','next week','the week after next','the week after the week after next']
	@bookings[calendar.index{ |x| x.include?(week.downcase) }] != nil and @bookings[calendar.index{ |x| x.include?(week.downcase) }] != ''
end

def book(array)
	@activities = @activities + 1
	unless array == ''
		cost = 0
		array.each_with_index do |x,i|
			if x != nil
				@bookings[i] = x
				puts "#{x} have been put in the diary for week #{i+1}."
				cost = cost + @bands[@bands.index { |y| y[0] == x }][4]
			end
		end
		@budget = @budget - cost
		sacked_broke
		puts "You have £#{@budget} left..."
	end
	activities_check
end

#methods for cleaning the venu

def hourlyClean
	(@capacity * (-0.08)) + 100
end

def clean(hours)
	@activities = @activities + 1
	if @cleanliness + (hourlyClean * hours) >= 100
		@cleanliness = 100
	else
		@cleanliness = @cleanliness + (hourlyClean*hours)
	end
	@budget = @budget - (hours * 25)
	puts "The venue is #{@cleanliness.to_i}% clean."
	sacked_broke
	puts "You have £#{@budget} left..."
	activities_check
end

#method for buying drinks in

def stock(hash)
	@activities = @activities + 1
	prices = { 	'Beer' => 1,
	 			'Wine' => 3,
	 			'Juice' => 2 }
	@budget = @budget - (prices['Beer']*hash['Beer']) - (prices['Wine']*hash['Wine']) - (prices['Juice']*hash['Juice'])
	@stock['Beer'] = @stock['Beer'] + hash['Beer']
	@stock['Wine'] = @stock['Wine'] + hash['Wine']
	@stock['Juice'] = @stock['Juice'] + hash['Juice']
	puts "You now have #{@stock['Beer']} bottles of beer, #{@stock['Wine']} bottles of wine, and #{@stock['Juice']} cartons of juice behind the bar."
	sacked_broke
	puts "You have £#{@budget} left in the coffers..."
	activities_check
end

#methods for checking whether you are sacked

def sacked_poor_performance
	if @warning >= 10
		"Oh dear, your manager has lost it. Just not good enough. You\'ve lost your job."
		exit
	end
end

def sacked_broke
	if @budget <= 0
		puts "Oh dear, there is no money left, at all. I think you know what that means. You are out of a job."
		exit
	end
end

#method for carrying out the weekly gig

def event

	@activities = 0

	puts "The venue is #{@cleanliness.to_i}% clean."
	if (@cleanliness < 50 and @cleanliness > 10)
		"Your manager is not impressed. The place looks pretty messy."
		@warning = @warning + 1
	elsif @cleanliness <= 10
		"The venue looks terrible. Your manager is not happy at all. He takes you aside for a bollocking."
		@warning = @warning + 5
	end
	sacked_poor_performance
	
	if (@stock['Beer'] + @stock['Wine'] + @stock['Juice']) <= 0
		puts "Jesus. You haven\'t got any drinks in! That just is not good enough. Your manager\'s lost it. And you\'ve lost your job."
		exit
	end

	band_index = @bands.index { |x| x[0]==@bookings[0] }
	gig_rating = @bands[band_index][3]
	gig_attendance = (gig_rating.to_f/100)*capacity
	gig_consumption = @bands[band_index][2]
	if ((gig_consumption[0].to_f/100)*gig_attendance) > @stock['Beer']
		beer_bottles_consumed = @stock['Beer']
	else
		beer_bottles_consumed = (gig_consumption[0].to_f/100)*gig_attendance
	end
	if (((gig_consumption[1].to_f/100)*gig_attendance)/6) > @stock['Wine']
		wine_bottles_consumed = @stock['Wine']
	else
		wine_bottles_consumed = ((gig_consumption[1].to_f/100)*gig_attendance)/6
	end
	if (((gig_consumption[2].to_f/100)*gig_attendance)/10) > @stock['Juice']
		juice_cartons_consumed = @stock['Juice']
	else
		juice_cartons_consumed = ((gig_consumption[2].to_f/100)*gig_attendance)/10
	end
	gig_messiness = @bands[band_index][1]

	puts "All set?..."

	if (@bookings[0] == '' or @bookings[0] == nil)
		puts "Oh my god. You haven\'t booked anyone to play! That is a monumental error. I\'m afraid that is the end of your time here."
		exit
	else
		puts "The doors open for this week\'s show. #{@bookings[0]} take to the stage."
		if gig_rating < 30
			puts "Oh dear. That was pretty shocking."
			puts "Your manager expects a better callabre than that..."
			@warning = @warning + 1
		elsif (gig_rating >= 30 and gig_rating < 70)
			puts "Cool. That wasn\'t bad."
		elsif gig_rating >= 70
			puts "Wow. That was incredible. They were shit hot."
			puts "Your manager is impressed."
			@warning = @warning - 1
		end
		sacked_poor_performance

		@cleanliness = @cleanliness - gig_messiness
		@stock['Beer'] = @stock['Beer'] - beer_bottles_consumed
		@stock['Wine'] = @stock['Wine'] - wine_bottles_consumed
		@stock['Juice'] = @stock['Juice'] - juice_cartons_consumed
		@budget = @budget + (gig_attendance*10) + (beer_bottles_consumed*4) + (wine_bottles_consumed*15) + (juice_cartons_consumed*5)

		puts "The aftermath..."

		puts "You now have #{@stock['Beer'].to_i} bottles of beer, #{@stock['Wine'].to_i} bottles of wine and #{@stock['Juice'].to_i} cartons of juice."
		if (@stock['Beer'] + @stock['Wine'] + @stock['Juice']) < 20
			puts "You are running very low on drinks! Your manager is concerned and takes you aside for a CHAT."
			@warning = @warning + 2
		elsif (@stock['Beer'] + @stock['Wine'] + @stock['Juice']) == 0
			puts "Oh dear. You ran out of drinks completely. Your manager is not happy at all. He gives you a major telling off."
			@warning = @warning + 5
		else
			if @stock['Beer'] == 0
				puts "You ran out of beer! Oh dear. Your manager is not happy."
				@warning = @warning + 1
			end
			if @stock['Wine'] == 0
				puts "You ran out of wine! Oh dear. Your manager is not happy."
				@warning = @warning + 1
			end
			if @stock['Juice'] == 0
				puts "You ran out of juice! Oh dear. Your manager is not happy."
				@warning = @warning + 1
			end
		end
		sacked_poor_performance

		puts "The venue is now #{@cleanliness.to_i}% clean."
	
		if @budget < @starting_budget
			puts "You have £#{@budget} in the coffers. That\'s less than you started with. The manager isn\'t happy - you need to up your game."
			@warning = @warning + 5
		elsif (@budget > @starting_budget and @budget < (@starting_budget * 10))
			puts "You have £#{@budget} in the coffers. That\'s more than you started with. Keep this up and you\'ll be fine."
			@warning = @warning - 2
		elsif @budget >= (@starting_budget * 10)
			puts "Wow wow wow. You\'ve put an extra zero on your starting budget. The manager calls you aside. And gives you a promotion!"
			puts "CONGRATULATIONS! YOU NAILED IT. YOU WON."
			exit
		else
			puts "You have £#{@budget} in the coffers. That\'s what you started with which. At least you haven\'t lost money. Not bad."
			@warning = @warning - 1
		end
		sacked_poor_performance

		@bookings.delete_at(0)
		@bookings.push('')
		if (@bookings[0] == '' or @bookings[0] == nil)
			puts "You donn\'t actually have an act booked yet for next week. The manager isn\'t impressed!"
			@warning = @warning + 2
		end

	end
end

end


#gameplay

puts "Congratulations on the new job, and good luck."
capacity = rand(801) + 200
budget = capacity * 3
venue = Venue.new(capacity,budget)
puts "You\'re running a new venue that\'s just opened. Here\'s the lowdown."
puts "You have a budget of £#{venue.budget}"
puts "The venue has a capacity of #{venue.capacity}"
puts "There\'s a weekly gig every Friday, which you need to book the act for. In any week you can have acts lined up for the next four Fridays."
puts "You also need to keep the venue clean and the bar stocked up."
puts "Bear in mind you only have enough time each week to get a limited amount done."
puts "Your manager\'s keeping a close eye on how you do..."
puts "Anyway, you should probably get started."
command = ''
while command != 'terminate'
	puts "Let me know whether you want to book the cleaners, buy some stock, or meet your promoter to find out what bands are available to book? Or do you want to press ahead with this week\'s gig?"
	command = gets.chomp.downcase
	if command.include?('cleaners')
		done = 0
		while done == 0
			puts "How many hours do you want to book them for? It\'s £25 an hour."
			answer = gets.chomp.downcase
			hours = []
			answer.chars.each do |x| 
				if ('0'..'9').to_a.include?(x)
				hours.push(x)
				end
			end
			if (hours.empty? or hours.join.to_i == 0)
				puts "I don\'t understand. How many hours? Or have you changed your mind?"
				answer = gets.chomp.downcase
				if answer == 'yes'
					done = 1
				end
			else
				"Ok. The cleaners are coming in."
				venue.clean(hours.join.to_i)
				done = 1
			end
		end
	elsif command.include?('stock')
		puts "Ok. You can buy beer, wine and/or juice."
		puts "Beer costs you £1 a bottle, wine is £3 a bottle and juice is £2 a carton."
		answer = 'yes'
		while answer == 'yes'
			hash = {}
			puts "How many beers will you get?"
			hash['Beer'] = gets.chomp.to_i
			puts "How many bottles of wine will you get?"
			hash['Wine'] = gets.chomp.to_i
			puts "And how many cartons of juice will you get?"
			hash['Juice'] = gets.chomp.to_i
			venue.stock(hash)
			puts "Do you want to get any more stock?"
			answer = gets.chomp.downcase
		end
		puts "Ok thanks."
	elsif command.include?('promoter') or command.include?('bands') or command.include?('book')
		puts "Right, the promoter is here. I\'ll hand over to her..."
		puts "Hi there. Here are the bands looking for gigs at the moment, and the price list..."
		venue.band_options
		puts "Do you want to book any of them now?"
		answer = gets.chomp.downcase
		if answer == 'yes'
			while answer != 'no'
				booking_array = []
				puts "Which band do you want to book now?"
				band = gets.chomp.split(' ').map{|x|x.capitalize}.join(' ')
				if venue.available_band?(band)
					puts "And when do you want to book them? This week, next week, the week after next or the week after the week after next?"
					week = gets.chomp.downcase
					calendar = ['this week','next week','the week after next','the week after the week after next']
					if venue.week_booked?(week)
						puts "You\'ve already got a booking that week. Do you want to cancel that and make this new booking?"
						answer = gets.chomp.downcase
						if answer == 'yes'
							booking_array[calendar.index{ |x| x.include?(week) }]=band
							venue.book(booking_array)
							puts "Do you want to book another band now?"
							answer = gets.chomp.downcase
						else
							puts "Ok. Do you to make a different booking?"
							answer = gets.chomp.downcase
						end
					else
						booking_array[calendar.index{ |x| x.include?(week) }]=band
						venue.book(booking_array)
						puts "Do you want to book another band now?"
						answer = gets.chomp.downcase
					end
				else
					if venue.valid_band?(band)
						puts "Sorry, they aren\'t available... They\'re already in the diary."
					else
						puts "Sorry, that isn\'t a valid band."
					end
					puts "Do you want to book another band?"
					answer = gets.chomp.downcase
				end
			end
		else
			puts "Oh right. Well, sorry to bother you then."
			venue.book('')
		end
		puts "Bye for now!"
	elsif command.include?('press') or command.include?('gig')
		puts "Ok. Exciting! Here we go..."
		venue.event
	else
		puts "Sorry. I don\'t understand. If you don\'t want to bother with this job, you can resign. Is that what you want?"
		answer = gets.chomp.downcase
		if answer == 'yes'
			command = 'terminate'
		end
	end
end
