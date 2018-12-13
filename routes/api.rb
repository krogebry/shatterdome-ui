
get '/api/1.0/stacks' do
  stacks = Shatterdome.get_stacks({}).map{|c| c['stack_name']}

  pp stacks

  data = []

  stacks.each do |stack_name|
    data.push({
                  stack_name: stack_name,
                  owner: 'owner',
                  type: 'type'
              })
  end

  {data: data}.to_json
end

post '/api/1.0/stack/create' do
  pp params

  ## Insert job to create stack.

  content_type 'application/json'
  {data: params, success: false}.to_json
end