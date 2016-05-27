# Encoding: UTF-8

attrs = node['resource_fantastical_app_test']

fantastical_app attrs['name'] do
  source attrs['source'] unless attrs['source'].nil?
  system_user attrs['system_user'] unless attrs['system_user'].nil?
  action attrs['action'] unless attrs['action'].nil?
end
