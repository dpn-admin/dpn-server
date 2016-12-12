# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe VersionController do
  describe 'GET #show' do
    context 'without authentication' do
      before(:each) { get :show }
      it_behaves_like 'an unauthenticated request'
    end
    context 'with authentication' do
      include_context 'with authentication'
      before(:each) { get :show }
      it 'returns application version' do
        versions = JSON.parse(response.body)
        expect(versions).to include 'app_version'
      end
      it 'returns API version' do
        versions = JSON.parse(response.body)
        expect(versions).to include 'api_version'
      end
    end
  end
end
