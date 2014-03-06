actions :install, :update
default_action :install
attribute :version, :required => true, :kind_of => String
attribute :install_user, :default => 'root', :kind_of => String
