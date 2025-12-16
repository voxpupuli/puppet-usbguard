# frozen_string_literal: true

require 'spec_helper'

describe 'usbguard::rule' do
  let(:pre_condition) { 'include usbguard' }
  let(:title) { 'allow with-interface equals { 08:*:* }' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_concat__fragment('/etc/usbguard/rules-managed-by-puppet.conf allow with-interface equals { 08:*:* }').
          with_target('/etc/usbguard/rules-managed-by-puppet.conf').
          with_content(<<~RULE).
            allow with-interface equals { 08:*:* }
          RULE
          with_order('500')
      end
    end
  end
end
