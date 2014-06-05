require 'sinatra'

set :server, 'webrick'

require 'rest_client'
require 'twitter'

def twitter_get 

	client = Twitter::REST::Client.new do |config|
	  config.consumer_key    = "9fOe6Z86v8wMT7GrhOepz5GXi"
	  config.consumer_secret = "eM8iGayXIT0eKwfYd0udXCeXkmFSBLfyof2c6m8Rg0X1RiQFXz"
	end
	return client

end

class Storyset
	def get_set(json_file, subset)
		
		resp = RestClient.get(json_file)
		doc = JSON.parse(resp)
		set = doc[subset]
		return set

	end
end

class Filters
	def get_list(type, set)

		list=[]
		set.each do |story|
			list << story[type]
		end
		puts list
		return list.sort
	end
end

get '/' do 

  if params[:set]
		@mashset = params[:set]
  else
  	@mashset = 'new'
  end

	all_stories = Storyset.new.get_set('http://mashable.com/stories.json', @mashset)

	#for filter menu
	@channels = Filters.new.get_list('channel', all_stories)
	@authors = Filters.new.get_list('author', all_stories)

	#set to render
	@stories = all_stories

	erb :home
	
end



get '/filter' do

	if params[:filter] && params[:type] && params[:set]

		all_stories = Storyset.new.get_set('http://mashable.com/stories.json', params[:set])

		#for filter menu
		if params[:type] == 'channel'
			@channels = Filters.new.get_list('channel', all_stories)
		end
		if params[:type] == 'author'
			@authors = Filters.new.get_list('author', all_stories)
		end

		@stories = all_stories.select { |v| v[params[:type]] == params[:filter] }

		# pass back so can set active buttons in UI
		@filter = params[:filter]
		@mashset = params[:set]

	else
		redirect '/'
	end

	erb :home

end


get '/tweets' do

	if params[:filter] && params[:type] && params[:set]
		all_stories = Storyset.new.get_set('http://mashable.com/stories.json', params[:set])

		#create timestamp
		time = Time.new

		# Format time
		
		@displaytime = "#{time.hour.to_s}:#{time.min.to_s} on #{time.month.to_s}/#{time.day.to_s}/#{time.year.to_s} "
		puts time.year    # => Year of the date 
		puts time.month   # => Month of the date (1 to 12)
		puts time.day     # => Day of the date (1 to 31 )
		puts time.wday    # => 0: Day of week: 0 is Sunday
		puts time.yday    # => 365: Day of year
		puts time.hour    # => 23: 24-hour clock
		puts time.min     # => 59
		puts time.sec     # => 59
		puts time.usec    # => 999999: microseconds
		puts time.zone    # => "UTC": timezone name

		@client = twitter_get

		@stories = all_stories.select { |v| v[params[:type]] == params[:filter] }
		@mashset = params[:set]



	else
		redirect '/'
	end

	erb :tweets

end



