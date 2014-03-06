action :install do
  # Resourceのattributeで定義したパラメータはnew_resource.(attribute名)で取得出来ます
  user = new_resource.install_user
  # providerの中では提供されているリソースを使うことが出来ます
  %w( autoconf openssl-devel readline-devel zlib-devel curl-devel procps git ).each do |pkg|
    package pkg do
      action :install
    end
  end

  execute 'git clone' do
    command 'git clone https://github.com/sstephenson/rbenv.git ~/.rbenv'
    user user
    not_if "ls -a ~ | grep -q '.rbenv'"
  end

  execute 'git clone ruby-build' do
    command 'git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build'
    user user
    not_if "ls -a ~/ | grep -q '.rbenv'"
  end

  bash 'set rbenv to environment' do
    user user
    code <<-EOH
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL -l
    EOH
    not_if "grep -q 'rbenv' ~/.bashrc"
  end

  bash 'install ruby' do
    user user
    code <<-EOH
    rbenv install -v #{new_resource.version}
    rbenv rehash
    rbenv global #{new_resource.version}
    EOH
  end
end

action :update do
  execute 'switch ruby version' do
    command "rbenv global #{new_resource.version}"
    user user
    only_if "rbenv versions | grep -q #{new_resource.version}"
  end
end
