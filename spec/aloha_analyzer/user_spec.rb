require 'spec_helper'

describe AlohaAnalyzer::User do
  subject(:user) { described_class.new(language, users) }
  let(:language) { 'en' }

  describe '#new' do
    let(:users) { [] }
    context 'when language is british' do
      let(:language) { 'en-gb' }

      it 'changes to english' do
        subject.language.should eq 'en'
      end
    end

    context 'when language is simplified chinese' do
      let(:language) { 'zh-cb' }

      it 'changes to chinese' do
        subject.language.should eq 'zh'
      end
    end

    context 'when language is tradiational chinese' do
      let(:language) { 'zh-tw' }

      it 'changes to chinese' do
        subject.language.should eq 'zh'
      end
    end

    context 'when language is something else' do
      let(:language) { 'something' }

      it 'does not change it' do
        subject.language.should eq language
      end
    end
  end

  describe '#analyze' do
    subject(:analyze) { described_class.new(language, users).analyze }
    context 'when no users' do
      let(:users) { [] }

      it 'returns a hash' do
        subject.should be_a Hash
      end

      it 'has no results with the user language' do
        subject[:with_user_language]['languages'].should eq({})
        subject[:with_user_language]['count'].should eq 0
      end

      it 'has no results without the user language' do
        subject[:without_user_language]['languages'].should eq({})
        subject[:without_user_language]['count'].should eq 0
      end
    end

    context 'when users' do
      context 'and no aliases' do
        let(:users) {
          [
            {'id' => '1', 'lang' => 'en'},
            {'id' => '2', 'lang' => 'fr'},
            {'id' => '3', 'lang' => 'en'},
            {'id' => '4', 'lang' => 'de'}
          ]
        }

        it 'returns a hash' do
          subject.should be_a Hash
        end

        it 'returns results based on the user language' do
          subject[:with_user_language].should == {
            'count' => 4,
            'languages' => {
              'en' => {
                'percentage' => 50,
                'count'      => 2,
                'language'   => {'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000, "countries"=>"USA, Canada, UK, Ireland, Australia"},
                'users'      => [{'id' => '1', 'lang' => 'en'}, {'id' => '3', 'lang' => 'en'}]
              },
              'fr' => {
                'percentage' => 25,
                'count'      => 1,
                'language' => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000, "countries"=>"France, Canada, Belgium, Switzerland"},
                'users'      => [{'id' => '2', 'lang' => 'fr'}]
              },
              'de' => {
                'percentage' => 25,
                'count'      => 1,
                'language' => {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000, "countries"=>"Germany, Austria, Switzerland, Belgium"},
                'users'      => [{'id' => '4', 'lang' => 'de'}]
              }
            }
          }
        end

        it 'returns results results based on the non user language' do
          subject[:without_user_language].should eq(
            'count' => 2,
            'languages' => {
              'fr' => {
                'percentage' => 50,
                'count'      => 1,
                'language'   => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000, 'countries' => 'France, Canada, Belgium, Switzerland'},
                'users'      => [{'id' => '2', 'lang' => 'fr'}]
              },
              'de' => {
                'percentage' => 50,
                'count'      => 1,
                'language'   => {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000, 'countries' => 'Germany, Austria, Switzerland, Belgium'},
                'users'      => [{'id' => '4', 'lang' => 'de'}]
              }
            }
          )
        end
      end

      context 'when only user langugages users' do
        let(:users) {
          [
            {'id' => '1', 'lang' => 'en'},
            {'id' => '2', 'lang' => 'en'}
          ]
        }

        it 'returns a hash' do
          subject.should be_a Hash
        end

        it 'returns results based on the user language' do
          subject[:with_user_language].should == {
            'count' => 2,
            'languages' => {
              'en' => {
                'percentage' => 100,
                'count'      => 2,
                'language'   => {'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000, 'countries' => 'USA, Canada, UK, Ireland, Australia'},
                'users'      => [{'id' => '1', 'lang' => 'en'}, {'id' => '2', 'lang' => 'en'}]
              }
            }
          }
        end

        it 'returns results results based on the non user language' do
          subject[:without_user_language]['languages'].should == {}
          subject[:without_user_language]['count'].should eq 0
        end
      end

      context 'when no users language users' do
        let(:users) {
          [
            {'id' => '1', 'lang' => 'de'},
            {'id' => '2', 'lang' => 'fr'}
          ]
        }

        it 'returns a hash' do
          subject.should be_a Hash
        end

        it 'returns results based on the user language' do
          subject[:with_user_language].should == {
            'count' => 2,
            'languages' => {
              'fr' => {
                'percentage' => 50,
                'count'      => 1,
                'language' => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000, 'countries' => 'France, Canada, Belgium, Switzerland'},
                'users' => [{'id' => '2', 'lang' => 'fr'}]
              },
              'de' => {
                'percentage' => 50,
                'count'      => 1,
                'language'   => {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000, 'countries' => 'Germany, Austria, Switzerland, Belgium'},
                'users'      => [{'id' => '1', 'lang' => 'de'}]
              }
            }
          }
        end

        it 'returns results results based on the non user language' do
          subject[:without_user_language].should eq(
            'count'     => 2,
            'languages' => {
              'fr' => {
                'percentage' => 50,
                'count'      => 1,
                'language' => { 'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000, 'countries' => 'France, Canada, Belgium, Switzerland' },
                'users' => [{'id' => '2', 'lang' => 'fr'}]
              },
              'de' => {
                'percentage' => 50,
                'count'      => 1,
                'language' => {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000, 'countries' => 'Germany, Austria, Switzerland, Belgium' },
                'users'      => [{'id' => '1', 'lang' => 'de'}]
              }
            }
          )
        end
      end

      context 'when aliases' do
        context 'and some users british' do
          let(:users) {
            [
              {'id' => '1', 'lang' => 'en'},
              {'id' => '2', 'lang' => 'fr'},
              {'id' => '3', 'lang' => 'en-GB'}
            ]
          }

          it 'merges english and british' do
            subject[:with_user_language].should == {
              'count' => 3,
              'languages' => {
                'en' => {
                  'percentage' => 66.67,
                  'count'      => 2,
                  'language'   => {'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000, 'countries' => 'USA, Canada, UK, Ireland, Australia' },
                  'users'      => [{'id' => '1', 'lang' => 'en'}, {'id' => '3', 'lang' => 'en'}]
                },
                'fr' => {
                  'percentage' => 33.33,
                  'count'      => 1,
                  'language' => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000, 'countries' => 'France, Canada, Belgium, Switzerland'},
                  'users'      => [{'id' => '2', 'lang' => 'fr'}]
                }
              }
            }

            subject[:without_user_language].should eq(
              'count' => 1,
              'languages' => {
                'fr' => {
                  'percentage' => 100,
                  'count'      => 1,
                  'language'   => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000, 'countries' => 'France, Canada, Belgium, Switzerland'},
                  'users'      => [{'id' => '2', 'lang' => 'fr'}]
                }
              }
            )
          end
        end

        context 'and some users are chinese' do
          let(:users) {
            [
              {'id' => '1', 'lang' => 'zh-cb'},
              {'id' => '2', 'lang' => 'zh-cb'},
              {'id' => '3', 'lang' => 'en'},
              {'id' => '4', 'lang' => 'zh-tw'}
            ]
          }

          it 'merges chinese' do
            subject[:with_user_language].should == {
              'count' => 4,
              'languages' => {
                'zh' => {
                  'percentage' => 75,
                  'count'      => 3,
                  'language'   => {'abbreviation'=>'zh', 'name'=>'Chinese', 'population'=>20000, 'countries' => 'China, Hong-Kong, Macau' },
                  'users'      => [{'id' => '1', 'lang' => 'zh'}, {'id' => '2', 'lang' => 'zh'}, {'id' => '4', 'lang' => 'zh'}]
                },
                'en' => {
                  'percentage' => 25,
                  'count'      => 1,
                  'language'=>{'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000, 'countries' => 'USA, Canada, UK, Ireland, Australia' },
                  'users' => [{'id' => '3', 'lang' => 'en'},]
                }
              }
            }

            subject[:without_user_language].should eq(
              'count' => 3,
              'languages' => {
                'zh' => {
                  'percentage' => 100,
                  'count'      => 3,
                  'language'=>{'abbreviation'=>'zh', 'name'=>'Chinese', 'population'=>20000, 'countries' => 'China, Hong-Kong, Macau' },
                  'users' => [{'id' => '1', 'lang' => 'zh'}, {'id' => '2', 'lang' => 'zh'}, {'id' => '4', 'lang' => 'zh'}]
                }
              }
            )
          end
        end
      end
    end
  end
end
