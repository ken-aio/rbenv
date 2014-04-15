action :install do
  # Resource定義のattributeで指定したパラメータはnew_resource.(attribute名)で取得出来ます
  install_dir = "#{new_resource.install_dir}/rbenv"

  # 1. 依存パッケージのインストール
  # 依存パッケージのインストールはRecipe内で定義します

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
end

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