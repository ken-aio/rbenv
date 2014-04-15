# attributes定義より、インストールするRubyのバージョン情報を取得
install_version = node[:rbenv][:switch_version][:version]
install_dir = node[:rbenv][:install][:dir]
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

