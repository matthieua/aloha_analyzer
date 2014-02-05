require 'spec_helper'

describe Aloha::Analyzer do
  subject(:follower) { described_class.new(screen_name, options) }
  let(:screen_name)     { 'mattaussaguel'  }

  let(:options) do
    {
      credentials: credentials
    }
  end

  let(:credentials) do
    {
      consumer_key:        'CK',
      consumer_secret:     'CS',
      access_token:        'AT',
      access_token_secret: 'AS'
    }
  end

  describe '#new' do
    it 'sets the screen_name' do
      subject.screen_name.should eq screen_name
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
    let(:followers) do
      {
        "users" => [
          {"id" => 1, "lang" => "en"},
          {"id" => 2, "lang" => "fr"},
          {"id" => 3, "lang" => "en"},
          {"id" => 4, "lang" => "de"}
        ],
        "next_cursor" => next_cursor
      }
    end
    let(:next_cursor) { 1 }
    let(:query_args) do
      {
        skip_status: false,
        count: 200,
        :cursor      => '-1',
        :screen_name => screen_name}
    end

    let(:body)    { followers.to_json }
    let(:headers) { {:content_type => 'application/json; charset=utf-8'} }

    before do
      stub_get('/1.1/followers/list.json')
        .with(:query => query_args)
        .to_return(:body => body, :headers => headers)
    end

    context 'when first call' do
      it 'sets the next cursor' do
        subject.calculate!

        subject.cursor.should eq next_cursor
      end

      it 'calculates the langauges stats' do
        subject.calculate!

        subject.languages.should eq(
          'en' => 2,
          'fr' => 1,
          'de' => 1
        )
      end

      it 'updates the count value' do
        subject.calculate!

        subject.count.should eq 4
      end

      it 'creates a new twitter client' do
        Twitter::REST::Client.should_receive(:new).and_call_original

        subject.calculate!
      end
    end

    context 'when run the second time' do
      let(:new_query_args) do
        {
          skip_status: false,
          count: 200,
          :cursor      => '1',
          :screen_name => screen_name}
      end

      let(:new_followers) do
        {
          "users" => [
            {"id" => 1, "lang" => "fr"},
            {"id" => 2, "lang" => "de"},
            {"id" => 3, "lang" => "es"},
            {"id" => 4, "lang" => "de"}
          ],
          "next_cursor" => new_next_cursor
        }
      end

      let(:new_next_cursor) { 1 }
      let(:new_body) { new_followers.to_json }

      before do
        subject.calculate!

        stub_get('/1.1/followers/list.json')
          .with(query: new_query_args)
          .to_return(body: new_body, headers: headers)

      end

      it 'sets the next cursor' do
        subject.calculate!

        subject.cursor.should eq new_next_cursor
      end

      it 'calculates the langauges stats' do
        subject.calculate!

        subject.languages.should eq(
          'en' => 2,
          'fr' => 2,
          'de' => 3,
          'es' => 1
        )
      end

      it 'updates the count value' do
        subject.calculate!

        subject.count.should eq 8
      end

      it 'does not create another twitter client' do
        Twitter::REST::Client.should_not_receive(:new)

        subject.calculate!
      end
    end
  end
end
