
get '/stacks' do
  erb :stacks
end

get '/stack/create' do
  erb 'stack/create'.to_sym
end

