get '/auth/login' do
  erb 'auth/login'.to_sym
end

get '/auth/logout' do
  session['user'] = nil
  redirect '/auth/login'
end

def auth_user(params)
  true
end

post '/auth/login' do
  if auth_user(params)
    session['user'] = params[:email]
  else
    redirect '/login?auth_failed'
  end

  redirect '/'
end