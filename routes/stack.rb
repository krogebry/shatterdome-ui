
get '/stacks' do
  erb :stacks
end

get '/stack/create' do
  stacks = []

  exclude_stacks = %i(Network Bastion ServiceGroup GenericASG)

  Shatterdome::Stacks.constants.select{|c|
    c unless c.match(/Exception/)
  }.select{|c|
    c unless exclude_stacks.include?(c)
  }.each do |stack_class_name|
    begin
      desc = Shatterdome::Stacks.const_get(stack_class_name)::DESCRIPTION
    rescue NameError
      desc = "No description"
    end

    stacks.push({
        description: desc,
        stack_class_name: stack_class_name
    })
  end

  erb 'stack/create'.to_sym, { locals: { stacks: stacks } }
end

