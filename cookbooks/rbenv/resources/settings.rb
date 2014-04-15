actions :install, :switch_version
default_action :install
attribute :version, :required => true, :kind_of => String
attribute :install_dir, :default => '/opt', :kind_of => String
