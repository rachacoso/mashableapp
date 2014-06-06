require 'sinatra'

set :server, 'webrick'

require 'rest_client'
require 'twitter'

MASHABLE_JSON = 'http://mashable.com/stories.json'

def twitter_get 

	client = Twitter::REST::Client.new do |config|
	  config.consumer_key    = "9fOe6Z86v8wMT7GrhOepz5GXi"
	  config.consumer_secret = "eM8iGayXIT0eKwfYd0udXCeXkmFSBLfyof2c6m8Rg0X1RiQFXz"
	end
	return client

end

def set_counts(set,count)
		newcount = "0"
		risingcount = "0"
		hotcount = "0"
	case set
	when "new"
		newcount = count
	when "rising"
		risingcount = count
	when "hot"
		hotcount = count
	end
	return newcount, risingcount, hotcount
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

		hash=Hash.new(0)

		set.each do |story|
			hash[story[type]] += 1
		end

		return hash
	end
end

get '/' do 
	
	# set defaults if nil or not defined
	@mashset = (params[:set].nil? || params[:set].empty?)? 'new' : params[:set]
	@articlecount = (params[:articlecount].nil? || params[:articlecount].empty?)? '10' : params[:articlecount]
	newcount, risingcount, hotcount = set_counts(@mashset,@articlecount)

	all_stories = Storyset.new.get_set("#{MASHABLE_JSON}?new_per_page=#{newcount}&rising_per_page=#{risingcount}&?hot_per_page=#{hotcount}", @mashset)

	#for filter menu
	@channels = Filters.new.get_list('channel', all_stories)
	@authors = Filters.new.get_list('author', all_stories)

	#set to render
	@stories = all_stories

	erb :home
	
end



get '/filter' do

	if params[:filter] && params[:type] && params[:set]

		# set defaults if nil or not defined
		@articlecount = (params[:articlecount].nil? || params[:articlecount].empty?)? '10' : params[:articlecount]

		newcount, risingcount, hotcount = set_counts(params[:set],@articlecount)

		all_stories = Storyset.new.get_set("#{MASHABLE_JSON}?new_per_page=#{newcount}&rising_per_page=#{risingcount}&?hot_per_page=#{hotcount}", params[:set])

		# all_stories = Storyset.new.get_set("#{MASHABLE_JSON}?new_per_page=#{@articlecount}&rising_per_page=#{@articlecount}&?hot_per_page=#{@articlecount}", params[:set])

		#for filter menu
		if params[:type] == 'channel'
			@channels = Filters.new.get_list('channel', all_stories)
		end
		if params[:type] == 'author'
			@authors = Filters.new.get_list('author', all_stories)
		end

		@stories = all_stories.select { |v| v[params[:type]] == params[:filter] } # get stories by channel or author

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

		@articlecount = (params[:articlecount].nil? || params[:articlecount].empty?)? '10' : params[:articlecount]

		all_stories = Storyset.new.get_set("#{MASHABLE_JSON}?new_per_page=#{@articlecount}&rising_per_page=#{@articlecount}&?hot_per_page=#{@articlecount}", params[:set])

		#create timestamp
		time = Time.new

		# Format time
		
		@displaytime = "#{time.hour}:#{time.min} on #{time.month}/#{time.day}/#{time.year} "

		@client = twitter_get

		@stories = all_stories.select { |v| v[params[:type]] == params[:filter] }  # get story by ID
		@mashset = params[:set]



	else
		redirect '/'
	end

	erb :tweets

end



