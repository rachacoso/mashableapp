require 'sinatra'
require 'rest_client'


def get_set(json_file, subset)
	
	resp = RestClient.get(json_file)
	doc = JSON.parse(resp)
	set = doc[subset]
	return set

end

def get_list(type, set)

	list=[]
	set.each do |story|
		list << story[type]
	end
	return list

end

get '/' do 

	all_stories = get_set('http://mashable.com/stories.json', 'new')

	#for filter menu
	@channels = get_list('channel', all_stories)
	@authors = get_list('author', all_stories)

	#set to render
	@stories = all_stories

	erb :home
	
end



get '/filter' do

	if params[:filter] && params[:type]

		all_stories = get_set('http://mashable.com/stories.json', 'new')

		#for filter menu
		@channels = get_list('channel', all_stories)
		@authors = get_list('author', all_stories)

		@stories = all_stories.select { |v| v[params[:type]] == params[:filter] }

	else
		redirect '/'
	end

	erb :home

end





