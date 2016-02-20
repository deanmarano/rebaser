require 'spec_helper'

describe "Spec examples" do
  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end

  context "without an explicit cassette name", vcr: {record: :new_episodes} do
    it 'records an http request' do
      expect(get('/').body).to eq 'Hello'
    end
  end
end
