# attributes定義より、rbenvをインストールするディレクトリ情報を取得します
install_dir = node[:rbenv][:install][:dir]

# 1. packageリソースを使って依存パッケージのインストールします
%w( gcc-c++ glibc-headers openssl-devel readline readline-devel zlib zlib-devel ).each do |pkg|
  package pkg do
    action :install
  end
end

# 2-1. gitリソースを使ってrbenv本体をインストール先ディレクトリに配置します
git 'install rbenv' do
  user 'root'
  destination install_dir
  repository 'https://github.com/sstephenson/rbenv.git'
  not_if "ls #{install_dir}"
end

# rbenvのプラグインインストール用のディレクトリを作成します
directory "#{install_dir}/plugins" do
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# 2-2. gitリソースを使ってrbenvのプライグインをインストールします
git 'install ruby-build' do
  user 'root'
  destination "#{install_dir}/plugins/ruby-build"
  repository "https://github.com/sstephenson/ruby-build.git"
  action :checkout
  not_if "ls #{install_dir}/plugins/ruby-build"
end

# 3. rbenv用の環境変数設定スクリプトを配置
env_file = '/etc/profile.d/rbenv.sh'
bash 'set rbenv to environment' do
  user 'root'
  code <<-EOH
  echo 'export RBENV_ROOT="#{install_dir}"' >> #{env_file}
  echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> #{env_file}
  echo 'eval "$(rbenv init -)"' >> #{env_file}
  EOH
  not_if "ls #{env_file}"
end

