# 依存パッケージのインストールはRedHat系とDebian系で分けます
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

# Ruby 2.1.1のインストール
rbenv_settings 'install ruby' do
  version '2.1.1'
  action :switch_version
end

# Ruby 2.1.0をインストールする場合
rbenv_settings 'install ruby' do
  version '2.1.0'
  action :switch_version
end
