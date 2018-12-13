
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

  job = {
      name: params['stack_name'],
      type: params['stack_type'],
      size: params['stack_size'],
      network: params['network'],
      version: params['stack_version']
  }

  queue_url = "https://sqs.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_ACCOUNT_ID']}/shatterdome_stacks"

  @client = Shatterdome.get_client('sqs')
  resp = @client.send_message({
                                  queue_url: queue_url,
                                  message_body: job.to_json,
                                  delay_seconds: 1
                              })

  content_type 'application/json'
  {data: params, success: false}.to_json
end