require 'sinatra'
require 'rest_client'

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
		return list
	end
end

get '/' do 

	all_stories = Storyset.new.get_set('http://mashable.com/stories.json', 'new')

	#for filter menu
	@channels = Filters.new.get_list('channel', all_stories)
	@authors = Filters.new.get_list('author', all_stories)

	#set to render
	@stories = all_stories

	erb :home
	
end



get '/filter' do

	if params[:filter] && params[:type]

		all_stories = Storyset.new.get_set('http://mashable.com/stories.json', 'new')

		#for filter menu
		@channels = Filters.new.get_list('channel', all_stories)
		@authors = Filters.new.get_list('author', all_stories)

		@stories = all_stories.select { |v| v[params[:type]] == params[:filter] }

	else
		redirect '/'
	end

	erb :home

end





