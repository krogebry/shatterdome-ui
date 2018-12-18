get '/api/1.0/launch_configs' do
  saved = DB['saved_launches'].find({ owner_email: session['user'] })
  data = []
  saved.each do |save|
    save['_id'] = save['_id'].to_s
    data.push save
  end
  {success: true, data: data}.to_json
end

get '/api/1.0/launch_config/:launch_config_id' do
  launch_config = DB['saved_launches'].find({_id: BSON::ObjectId(params[:launch_config_id])}).first
  launch_config['_id'] = launch_config['_id'].to_s
  {success: true, data: launch_config}.to_json
end

post '/api/1.0/launch_config' do
  data = params.merge({owner_email: session['user']})
  DB['saved_launches'].find_one_and_update(
      { launch_name: data['launch_name'] },
      { "$set" => data },
      { :upsert => true })
  {success: true}.to_json
end
