# attributes定義より、rbenvをインストールするディレクトリ情報を取得する
install_dir = node[:rbenv][:install][:dir]

# 1. 依存パッケージのインストール
%w( autoconf openssl-devel readline-devel zlib-devel curl-devel gcc-c++ procps git ).each do |pkg|
  package pkg do
    action :install
  end
end

# 2-1. rbenv本体をインストール先ディレクトリに配置
execute 'git clone rbenv' do
  user 'root'
  command "git clone https://github.com/sstephenson/rbenv.git #{install_dir}"
  not_if "ls #{install_dir}"
end

# 2-2. rbenvのプライグインをインストール
execute 'git clone ruby-build' do
  user 'root'
  command "git clone https://github.com/sstephenson/ruby-build.git #{install_dir}/plugins/ruby-build"
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

