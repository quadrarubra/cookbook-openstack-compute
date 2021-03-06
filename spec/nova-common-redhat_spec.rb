# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-compute::nova-common' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'compute_stubs'
    include_examples 'expect_creates_nova_state_dir'
    include_examples 'expect_creates_nova_lock_dir'

    it 'upgrades nova common package' do
      expect(chef_run).to upgrade_package 'openstack-nova-common'
    end

    it 'upgrades mysql python package' do
      expect(chef_run).to upgrade_package 'MySQL-python'
    end

    it 'upgrades memcache python packages' do
      expect(chef_run).to upgrade_package 'python-memcached'
    end

    describe 'nova.conf' do
      let(:file) { chef_run.template('/etc/nova/nova.conf') }

      [/^ec2_private_dns_show_ip=True$/, /^force_dhcp_release=false$/].each do |content|
        it "has a #{content.source[1...-1]} line" do
          expect(chef_run).to render_file(file.name).with_content(content)
        end
      end
    end
  end
end
