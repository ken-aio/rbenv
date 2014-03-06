action :install do
  # Resourceのattributeで定義したパラメータはnew_resource.(attribute名)で取得出来ます
  user = new_resource.install_user
  # providerの中では提供されているリソースを使うことが出来ます
  package 'git' do
    action :install
  end

  execute 'git clone' do
    command 'git clone https://github.com/sstephenson/rbenv.git ~/.rbenv'
    user user
  end
end

action :update do
end
