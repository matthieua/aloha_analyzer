require 'spec_helper'

describe AlohaAnalyzer::FacebookPage do
  # {"tr_TR"=>3677, "en_US"=>89, "ka_GE"=>49, "en_GB"=>44, "az_AZ"=>39, "fr_FR"=>35, "bg_BG"=>28, "ru_RU"=>20, "de_DE"=>19, "ar_AR"=>8, "fr_CA"=>6, "es_LA"=>6, "nl_NL"=>4, "sq_AL"=>3, "pl_PL"=>2, "pt_BR"=>2, "es_ES"=>2, "it_IT"=>2, "lt_LT"=>1, "da_DK"=>1, "cs_CZ"=>1, "el_GR"=>1, "sr_RS"=>1, "et_EE"=>1, "mk_MK"=>1, "en_IN"=>1, "pt_PT"=>1, "jv_ID"=>1}
  subject(:facebook_page) { described_class.new(options) }
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
      let(:users) { {} }

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
        let(:users) do
          {
            'en' => 2,
            'fr' => 1,
            'de' => 1
          }
        end

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
            'users'    => []
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
              'users'    => []
              },
              'de' => {
                'count'    => 1,
                'language' => {'abbreviation'=>'de', 'name'=>'German', 'greeting'=>'hallo!', 'population'=>30000000, 'countries'=>'Germany, Austria, Switzerland, Belgium'},
                'users'    => []
              }
            })
          end
        end

        context 'when only user langugages users' do
          let(:users) do
            {
              'en' => 2
            }
          end

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
              'users'      => []
            })
          end

          it 'returns results results based on the non user language' do
            expect(subject['foreign_languages']).to eq({})
            expect(subject['foreign_languages_count']).to eq 0
          end
        end

        context 'when no users language users' do
          let(:users) do
            {
              'de' => 1,
              'fr' => 2
            }
          end

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
                'users' => []
                },
                'de' => {
                  'count'    => 1,
                  'language' => {'abbreviation'=>'de', 'name'=>'German', 'greeting'=>'hallo!', 'population'=>30000000, 'countries' => 'Germany, Austria, Switzerland, Belgium' },
                  'users'    => []
                }
                )
          end
        end

        context 'when aliases' do
          let(:users) do
            {
              'en'    => 1,
              'en_US' => 1,
              'fr'    => 1
            }
          end

          it 'includes the total count' do
            expect(subject['count']).to eq 3
          end

          it 'includes the user lanugage' do
            expect(subject['account_language']).to eq({
              'count'      => 2,
              'language'   => { 'abbreviation'=>'en', 'greeting' => 'hello!', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia' },
              'users'      => []
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
                'users'      => []
              }
            )
          end
        end
      end

      context 'when existing analysis' do
        let(:users) do
          {
            'en' => 1,
            'fr' => 1
          }
        end

        let(:analysis) do
          {
            'account_language' => {
              'count'      => 2,
              'language'   => { 'abbreviation'=>'en', 'greeting' => 'hello!', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia' },
              'users'      => []
            },
            'foreign_languages_count' => 1,
            'count'                   => 3,
            'foreign_languages'       => {
              'fr' => {
                'count'      => 1,
                'language'   => {'abbreviation'=>'fr', 'name'=>'French', 'greeting'=>'bonjour!', 'population'=>45000000, 'countries' => 'France, Canada, Belgium, Switzerland'},
                'users'      => []
              }
            }
          }
        end

        it 'starts from the existing analysis' do
          expect(subject).to eq(
            'account_language' => {
              'count'    => 3,
              'language' => {'abbreviation'=>'en', 'greeting'=>'hello!', 'name'=>'English', 'population'=>360000000, 'countries'=>'USA, UK, Canada, Ireland, Australia'},
              'users'    => []
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
                'users' => []
              }
            }
          )
        end
      end
    end
end
