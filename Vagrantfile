# Launch graylog2 in a VM with a single command
# vagrantup.com

Vagrant::Config.run do |config|
  config.vm.box = "lucid64"

  # Forward the vm's port 80 to your 8080
  config.vm.forward_port 80, 8080

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe "graylog2::server"
    chef.add_recipe "graylog2::web_interface"
    chef.add_recipe "graylog2::apache2"
    # Specify chef attributes
    # chef.json.merge!({
    #   :graylog2 => {
    #     :send_stream_subscriptions => false
    #   }
    # })
  end
end
