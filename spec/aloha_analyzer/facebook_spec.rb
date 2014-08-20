require 'spec_helper'

describe AlohaAnalyzer::Facebook do
  subject(:facebook) { described_class.new(options) }
  let(:language)     { 'en' }
  let(:options) do
    {
      'language' => language,
      'analysis' => analysis
    }
  end
  let(:analysis) { nil }

  describe '#new' do
    context 'when language is british' do
      let(:language) { 'en-gb' }

      it 'changes to english' do
        expect(subject.language).to eq 'en'
      end
    end

    context 'when language is simplified chinese' do
      let(:language) { 'zh-cn' }

      it 'changes to chinese' do
        expect(subject.language).to eq 'zh'
      end
    end

    context 'when language is tradiational chinese' do
      let(:language) { 'zh-tw' }

      it 'changes to chinese' do
        expect(subject.language).to eq 'zh'
      end
    end

    context 'when analysis is not nil' do
      let(:analysis) { { foo: :bar } }

      it 'sets the analysis to the argument' do
        expect(subject.analysis).to eq analysis
      end

      it 'clones the hash' do
        expect(subject.analysis.object_id).not_to eq analysis.object_id
      end
    end

    context 'when analysis is nil' do
      let(:analysis) { nil }

      it 'sets the analysis to the analysis boilerplate' do
        expect(subject.analysis).to eq subject.boilerplate
      end

      it 'clones the hash' do
        expect(subject.analysis.object_id).not_to eq subject.boilerplate.object_id
      end
    end
  end

  describe '#analyze' do
    subject(:results) { described_class.new(options).analyze(users) }
    context 'when no users' do
      let(:users) { [] }

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'includes the total count' do
        expect(subject['count']).to eq 0
      end

      it 'has no results with the user language' do
        expect(subject['account_language']['count']).to eq 0
      end

      it 'has no results without the user language' do
        expect(subject['foreign_languages']).to eq({})
        expect(subject['foreign_languages_count']).to eq 0
      end

      it 'includes the user lanugage' do
        expect(subject['account_language']['language']).to eq(
          'abbreviation'=>'en', 'greeting' => 'hello!', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia'
          )
      end
    end

    context 'when users' do
      context 'and no aliases' do
        let(:users) {
          [
            {'id' => '1', 'locale' => 'en'},
            {'id' => '2', 'locale' => 'fr'},
            {'id' => '3', 'locale' => 'en'},
            {'id' => '4', 'locale' => 'de'}
          ]
        }

        it 'returns a hash' do
          expect(subject).to be_a Hash
        end

        it 'includes the total count' do
          expect(subject['count']).to eq 4
        end

        it 'includes the user lanugage' do
          expect(subject['account_language']).to eq(
            'count'    => 2,
            'language' => {'abbreviation'=>'en', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia', 'greeting'=>'hello!'},
            'users'    => [{'id' => '1', 'locale' => 'en'}, {'id' => '3', 'locale' => 'en'}]
            )
        end

        it 'includs the foreign followers count' do
          expect(subject['foreign_languages_count']).to eq 2
        end

        it 'returns results based on the user language' do
          expect(subject['foreign_languages']).to eq({
            'fr' => {
              'count'    => 1,
              'language' => {'abbreviation'=>'fr', 'name'=>'French', 'greeting'=>'bonjour!', 'population'=>45000000, 'countries'=>'France, Canada, Belgium, Switzerland'},
              'users'    => [{'id' => '2', 'locale' => 'fr'}]
              },
              'de' => {
                'count'    => 1,
                'language' => {'abbreviation'=>'de', 'name'=>'German', 'greeting'=>'hallo!', 'population'=>30000000, 'countries'=>'Germany, Austria, Switzerland, Belgium'},
                'users'    => [{'id' => '4', 'locale' => 'de'}]
              }
            })
          end
        end

        context 'when unknown language' do
          let(:users) do
            [
              {'id' => '1', 'locale' => 'unknown'},
              {'id' => '2', 'locale' => 'something'},
              {'id' => '3', 'locale' => 'en-GB'}
            ]
          end

          it 'returns a hash' do
            expect(subject).to be_a Hash
          end

          it 'includes the total count' do
            expect(subject['count']).to eq 3
          end

          it 'includes the correct foreign_languages_count' do
            expect(subject['foreign_languages_count']).to eq 2
          end

          it 'returns results results based on the non user language' do
            expect(subject['foreign_languages']).to eq(
                'other' => {
                  'count'    => 2,
                  'language' => {'abbreviation'=>'other', 'name'=>'Other', 'greeting'=>'', 'population'=>nil, 'countries' => '' },
                  'users'=> [{'id'=>'1', 'locale'=>'unknown'}, {'id'=>'2', 'locale'=>'something'}]
                }
              )
          end
        end

        context 'when only user langugages users' do
          let(:users) {
            [
              {'id' => '1', 'locale' => 'en'},
              {'id' => '2', 'locale' => 'en'}
            ]
          }

          it 'returns a hash' do
            expect(subject).to be_a Hash
          end

          it 'includes the total count' do
            expect(subject['count']).to eq 2
          end

          it 'includes the user lanugage' do
            expect(subject['account_language']['language']).to eq(
              'abbreviation'=>'en', 'greeting' => 'hello!', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia'
              )
          end

          it 'returns results based on the user language' do
            expect(subject['account_language']).to eq({
              'count'      => 2,
              'language'   => {'abbreviation'=>'en', 'name'=>'English', 'population'=>360000000, 'countries' => 'USA, UK, Canada, Ireland, Australia', 'greeting'=>'hello!'},
              'users'      => [{'id' => '1', 'locale' => 'en'}, {'id' => '2', 'locale' => 'en'}]
            })
          end

          it 'returns results results based on the non user language' do
            expect(subject['foreign_languages']).to eq({})
            expect(subject['foreign_languages_count']).to eq 0
          end
        end

        context 'when no users language users' do
          let(:users) {
            [
              {'id' => '1', 'locale' => 'de'},
              {'id' => '2', 'locale' => 'fr'},
              {'id' => '3', 'locale' => 'fr'}
            ]
          }

          it 'returns a hash' do
            expect(subject).to be_a Hash
          end

          it 'includes the total count' do
            expect(subject['count']).to eq 3
          end

          it 'returns results based on the user language' do
            expect(subject['account_language']).to eq({
              'count'      => 0,
              'language'   => {'abbreviation'=>'en', 'greeting' => 'hello!', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia'},
              'users'      => []
            })
          end

          it 'includes the correct foreign_languages_count' do
            expect(subject['foreign_languages_count']).to eq 3
          end

          it 'returns results results based on the non user language' do
            expect(subject['foreign_languages']).to eq(
              'fr' => {
                'count'      => 2,
                'language' => { 'abbreviation'=>'fr', 'name'=>'French', 'greeting'=>'bonjour!', 'population'=>45000000, 'countries' => 'France, Canada, Belgium, Switzerland' },
                'users' => [{'id' => '2', 'locale' => 'fr'}, {'id' => '3', 'locale' => 'fr'}]
                },
                'de' => {
                  'count'    => 1,
                  'language' => {'abbreviation'=>'de', 'name'=>'German', 'greeting'=>'hallo!', 'population'=>30000000, 'countries' => 'Germany, Austria, Switzerland, Belgium' },
                  'users'    => [{'id' => '1', 'locale' => 'de'}]
                }
                )
          end
        end

        context 'when aliases' do
          let(:users) {
            [
              {'id' => '1', 'locale' => 'en'},
              {'id' => '2', 'locale' => 'fr'},
              {'id' => '3', 'locale' => 'en_US'}
            ]
          }

          it 'includes the total count' do
            expect(subject['count']).to eq 3
          end

          it 'includes the user lanugage' do
            expect(subject['account_language']).to eq({
              'count'      => 2,
              'language'   => { 'abbreviation'=>'en', 'greeting' => 'hello!', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia' },
              'users'      => [{'id' => '1', 'locale' => 'en'}, {'id' => '3', 'locale' => 'en'}]
            })
          end

          it 'includes the correct foreign_languages_count' do
            expect(subject['foreign_languages_count']).to eq 1
          end

          it 'merges english and british' do
            expect(subject['foreign_languages']).to eq(
              'fr' => {
                'count'      => 1,
                'language'   => {'abbreviation'=>'fr', 'name'=>'French', 'greeting'=>'bonjour!', 'population'=>45000000, 'countries' => 'France, Canada, Belgium, Switzerland'},
                'users'      => [{'id' => '2', 'locale' => 'fr'}]
              }
            )
          end
        end
      end

      context 'when user limit per language' do
        let(:options) do
          {
            'language'  => language,
            'analysis'  => analysis,
            'max_users' => 1
          }
        end
        let(:users) {
          [
            {'id' => '1', 'locale' => 'en'},
            {'id' => '2', 'locale' => 'fr'},
            {'id' => '3', 'locale' => 'en'},
            {'id' => '4', 'locale' => 'fr'},
            {'id' => '5', 'locale' => 'fr'}
          ]
        }

        it 'limits the number of account language users to 1' do
          expect(subject['account_language']['users'].size).to eq 1
        end

        it 'limits the number of foreign languages users to 1' do
          expect(subject['foreign_languages']['fr']['users'].size).to eq 1
        end

        it 'does not affect the account language count' do
          expect(subject['account_language']['count']).to eq 2
        end

        it 'does not affect the foreign_languages_count' do
          expect(subject['foreign_languages_count']).to eq 3
        end

        it 'does not affect the total count' do
          expect(subject['count']).to eq 5
        end

        it 'does not affect a foreign language count' do
          expect(subject['foreign_languages']['fr']['count']).to eq 3
        end
      end

      context 'when existing analysis' do
        let(:users) {
          [
            {'id' => '4', 'locale' => 'en'},
            {'id' => '5', 'locale' => 'fr'}
          ]
        }

        let(:analysis) do
          {
            'account_language' => {
              'count'      => 2,
              'language'   => { 'abbreviation'=>'en', 'greeting' => 'hello!', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia' },
              'users'      => [{'id' => '1', 'locale' => 'en'}, {'id' => '3', 'locale' => 'en'}]
            },
            'foreign_languages_count' => 1,
            'count'                   => 3,
            'foreign_languages'       => {
              'fr' => {
                'count'      => 1,
                'language'   => {'abbreviation'=>'fr', 'name'=>'French', 'greeting'=>'bonjour!', 'population'=>45000000, 'countries' => 'France, Canada, Belgium, Switzerland'},
                'users'      => [{'id' => '2', 'locale' => 'fr'}]
              }
            }
          }
        end

        it 'starts from the existing analysis' do
          expect(subject).to eq(
            'account_language' => {
              'count'    => 3,
              'language' => {'abbreviation'=>'en', 'greeting'=>'hello!', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia'},
              'users'    => [{'id'=>'1', 'locale'=>'en'}, {'id'=>'3', 'locale'=>'en'}, {'id'=>'4', 'locale'=>'en'}]
            },
            'foreign_languages_count' => 2,
            'count'                   => 5,
            'foreign_languages'       => {
              'fr' => {
                'count'    => 2,
                'language' => {
                  'abbreviation' => 'fr',
                  'name'         => 'French',
                  'greeting'     => 'bonjour!',
                  'population'   => 45000000,
                  'countries'    => 'France, Canada, Belgium, Switzerland'
                },
                'users' => [{'id'=>'2', 'locale'=>'fr'}, {'id'=>'5', 'locale'=>'fr'}]
              }
            }
          )
        end
      end
    end
end
