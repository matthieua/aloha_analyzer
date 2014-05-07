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
        subject[:with_user_language].should eq({})
      end

      it 'has no results without the user language' do
        subject[:without_user_language].should eq({})
      end
    end

    context 'when users' do
      context 'and no aliases' do
        let(:users) {
          [
            {'lang' => 'en'},
            {'lang' => 'fr'},
            {'lang' => 'en'},
            {'lang' => 'de'}
          ]
        }

        it 'returns a hash' do
          subject.should be_a Hash
        end

        it 'returns results based on the user language' do
          subject[:with_user_language].should == {
            'en' => {
              'percentage' => 50,
              'count'      => 2,
              'language' => {'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000},
            },
            'fr' => {
              'percentage' => 25,
              'count'      => 1,
              'language' => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000},
            },
            'de' => {
              'percentage' => 25,
              'count'      => 1,
              'language' => {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000}
            }
          }
        end

        it 'returns results results based on the non user language' do
          subject[:without_user_language].should eq(
            'fr' => {
              'percentage' => 50,
              'count'      => 1,
              'language' => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000},
            },
            'de' => {
              'percentage' => 50,
              'count'      => 1,
              'language' => {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000}
            }
          )
        end
      end

      context 'when only user langugages users' do
        let(:users) {
          [
            {'lang' => 'en'},
            {'lang' => 'en'}
          ]
        }

        it 'returns a hash' do
          subject.should be_a Hash
        end

        it 'returns results based on the user language' do
          subject[:with_user_language].should == {
            'en' => {
              'percentage' => 100,
              'count'      => 2,
              'language' => {'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000},
            }
          }
        end

        it 'returns results results based on the non user language' do
          subject[:without_user_language].should == {}
        end
      end

      context 'when no users language users' do
        let(:users) {
          [
            {'lang' => 'de'},
            {'lang' => 'fr'}
          ]
        }

        it 'returns a hash' do
          subject.should be_a Hash
        end

        it 'returns results based on the user language' do
          subject[:with_user_language].should == {
            'fr' => {
              'percentage' => 50,
              'count'      => 1,
              'language' => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000},
            },
            'de' => {
              'percentage' => 50,
              'count'      => 1,
              'language' => {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000}
            }
          }
        end

        it 'returns results results based on the non user language' do
          subject[:without_user_language].should eq(
            'fr' => {
              'percentage' => 50,
              'count'      => 1,
              'language' => { 'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000 },
            },
            'de' => {
              'percentage' => 50,
              'count'      => 1,
              'language' => {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000}
            }
          )
        end
      end

      context 'when aliases' do
        context 'and some users british' do
          let(:users) {
            [
              {'lang' => 'en'},
              {'lang' => 'fr'},
              {'lang' => 'en-GB'}
            ]
          }

          it 'merges english and british' do
            subject[:with_user_language].should == {
              'en' => {
                'percentage' => 67,
                'count'      => 2,
                'language'=>{'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000},
              },
              'fr' => {
                'percentage' => 33,
                'count'      => 1,
                'language' => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000}
              }
            }

            subject[:without_user_language].should eq(
              'fr' => {
                'percentage' => 100,
                'count'      => 1,
                'language' => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000}
              }
            )
          end
        end

        context 'and some users are chinese' do
          let(:users) {
            [
              {'lang' => 'zh-cb'},
              {'lang' => 'zh-cb'},
              {'lang' => 'en'},
              {'lang' => 'zh-tw'}
            ]
          }

          it 'merges chinese' do
            subject[:with_user_language].should == {
              'zh' => {
                'percentage' => 75,
                'count'      => 3,
                'language'=>{'abbreviation'=>'zh', 'name'=>'Chinese', 'population'=>20000}
              },
              'en' => {
                'percentage' => 25,
                'count'      => 1,
                'language'=>{'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000}
              }
            }

            subject[:without_user_language].should eq(
              'zh' => {
                'percentage' => 100,
                'count'      => 3,
                'language'=>{'abbreviation'=>'zh', 'name'=>'Chinese', 'population'=>20000}
              }
            )
          end
        end
      end
    end
  end
end
