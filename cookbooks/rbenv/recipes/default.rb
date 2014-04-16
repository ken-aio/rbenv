# 依存パッケージのインストールをRedHat系とDebian系で分岐
case node[:platform]
when 'redhat', 'centos'
  packages = %w( gcc-c++ glibc-headers openssl-devel readline readline-devel zlib zlib-devel )
when 'debian', 'ubuntu'
  packages = %w( autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev )
end

packages.each do |pkg|
  package pkg do
    action :install
  end
end

# rbenvのインストール
# Resource定義でinstallをデフォルトactionにしたので、actionは指定する必要はない
rbenv_settings 'install rbenv'

# Ruby 2.1.1をインストールして有効にする
rbenv_settings 'install ruby' do
  version '2.1.1'
  action :switch_version
end

# 試しにRuby 2.1.0を追加でインストールして有効にしてみる
rbenv_settings 'install ruby' do
  version '2.1.1'
  action :switch_version
end
