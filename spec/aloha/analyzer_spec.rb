require 'spec_helper'

describe Aloha::Analyzer do
  subject(:follower) { described_class.new(username, options) }
  let(:username)     { 'mattaussaguel'  }
  let(:options) do
    {
      credentials: credentials
    }
  end

  let(:credentials) do
    {
      consumer_key:        'consumer_key',
      consumer_secret:     'consumer_secret',
      access_token:        'access_token',
      access_token_secret: 'access_token_secret'
    }
  end

  describe '#new' do
    it 'sets the username' do
      subject.username.should eq username
    end

    context 'cursor option is passed' do
      let(:options) { { cursor: cursor } }
      let(:cursor)  { double }

      it 'sets the cursor to the option value' do
        subject.cursor.should eq cursor
      end
    end

    context 'cursor option is not set' do
      it 'sets the cursor to -1' do
        subject.cursor.should eq -1
      end
    end

    context 'when languages option are passed' do
      let(:languages) { double }
      let(:options) { { languages: languages } }

      it 'sets the languages to the option value' do
        subject.languages.should eq languages
      end
    end

    context 'when languages option is not set' do
      it 'sets the cursor to an empty hash' do
        subject.languages.should be_a Hash
        subject.languages.should be_empty
      end
    end
  end

  describe '#count' do
    let(:options) { { languages: languages } }
    let(:languages) do
      {
        'en' => 2,
        'fr' => 3,
        'es' => 0
      }
    end

    it 'includes the total language count' do
      subject.count.should eq 5
    end
  end

  describe '#calculate!' do
    it 'returns a retuns object' do
      pending
      subject.calculate!

      puts subject.to_h.inspect
    end
  end
end
