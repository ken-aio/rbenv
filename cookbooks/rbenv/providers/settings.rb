# install actionを実装します
action :install do
  # Resource定義のattributeで指定したパラメータはnew_resource.(attribute名)で取得出来ます
  install_dir = "#{new_resource.install_dir}/rbenv"
  env_file = '/etc/profile.d/rbenv.sh'

  # 1. 依存パッケージのインストール
  # 依存パッケージのインストールはRecipe内で定義します

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
  bash 'set rbenv to environment' do
    user 'root'
    code <<-EOH
    echo 'export RBENV_ROOT="#{install_dir}"' >> #{env_file}
    echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> #{env_file}
    echo 'eval "$(rbenv init -)"' >> #{env_file}
    EOH
    not_if "ls #{env_file}"
  end
end

# switch_version actionを実装します
action :switch_version do
  # Resource定義のattributeで指定したパラメータはnew_resource.(attribute名)で取得出来ます
  install_version = new_resource.version
  install_dir = "#{new_resource.install_dir}/rbenv"
  rbenv_path = "RBENV_ROOT=#{install_dir} #{install_dir}/bin"

  # rbenvを使ってRubyをインストール
  bash 'install ruby' do
    user 'root'
    code <<-EOH
    #{rbenv_path}/rbenv install #{install_version}
    #{rbenv_path}/rbenv rehash
    #{rbenv_path}/rbenv global #{install_version}
    EOH
    only_if do
      `#{rbenv_path}/rbenv install -l | grep -wc #{install_version}`.to_i > 0 &&
      `#{rbenv_path}/rbenv versions | grep -wc #{install_version}`.to_i == 0
    end
  end

  # インストールしたRubyを有効にする
  bash 'switch ruby version' do
    user 'root'
    code <<-EOH
    #{rbenv_path}/rbenv rehash
    #{rbenv_path}/rbenv global #{install_version}
    EOH
    only_if "#{rbenv_path}/rbenv versions | grep -w #{install_version}"
  end
end
