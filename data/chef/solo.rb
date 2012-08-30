
root = File.absolute_path(File.dirname(__FILE__))

data_bag_path root + '/data-bags'
file_cache_path root
role_path root + '/roles'

# Later entries override earlier ones:
cookbook_path [ root + '/cookbooks' ]