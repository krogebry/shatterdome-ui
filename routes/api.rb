
get '/api/1.0/flush_cache' do
  CACHE.flush
  {success: true}.to_json
end

get '/api/1.0/stacks' do
  stacks = Shatterdome.get_stacks({})

  pp stacks

  data = []

  stacks.each do |stack|
    data.push({
                  stack_name: stack['stack_name'],
                  status: stack['stack_status'],
                  owner: 'owner',
                  type: 'type'
              })
  end

  pp data

  {data: data}.to_json
end

get '/api/1.0/stack/elements/:stack_type' do
  config = Psych.safe_load(File.read(File.join('etc', 'stacks.yaml')), [], [], true)
  el = config.select{|c| c['type'] == params['stack_type']}.first

  el = { 'elements' => [] } if el.nil?

  content = ""
  el['elements'].each do |el_name|
    if params['stack_type']  == 'ECSService'
      zones = Shatterdome.get_hosted_zones['hosted_zones']
      clusters = Shatterdome.get_stacks({Role: 'Cluster'})
      content += erb "stack/elements/#{el_name}".to_sym, {layout: :empty, locals: {clusters: clusters, zones: zones}}
    else
      content += erb "stack/elements/#{el_name}".to_sym, {layout: :empty}
    end
  end

  content_type 'application/json'
  {success: true, content: content}.to_json
end
