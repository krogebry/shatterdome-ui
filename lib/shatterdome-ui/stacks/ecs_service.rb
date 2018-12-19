module ShatterdomeUI
  module Stacks
    class ECSService < ShatterdomeUI::Stack

      def converge
        @config['dns'] = {
            name: @params['dns'],
            hosted_zone_name: @params['dns_domain']
        }
        @config['cluster'] = @params['cluster']
        @config['public'] = @params['public']
        @config['ports'] = [@params['port'].to_i]
        @config['health_check'] = {
            url: @params['health_check_url'],
            code: @params['health_check_code']
        }

        @config['cpu'] = 1024
        @config['num'] = 1
        @config['mem'] = 500

        @config['name'] = @params['stack_name']

        @config['image'] = {
            name: @params['image'],
            label: @params['label']
        }

        stack = Shatterdome.get_stack_by_name(params['cluster'])
        @config['cluster_name'] = stack['tags'].select {|t| t['key'] == 'Name'}.first['value']
        @config['cluster_version'] = stack['tags'].select {|t| t['key'] == 'Version'}.first['value']
      end
    end
  end
end