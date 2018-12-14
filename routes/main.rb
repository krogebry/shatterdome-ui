
get '/' do
  erb :index
end

get '/version' do
  {version: ShatterdomeUI::VERSION}.to_json
end

get '/healthz' do
  {success: true}.to_json
end

