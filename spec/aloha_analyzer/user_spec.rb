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
      let(:language) { 'zh-cn' }

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
        subject[:user_language][:count].should eq 0
      end

      it 'has no results without the user language' do
        subject[:foreign_languages].should eq({})
        subject[:foreign_languages_count].should eq 0
      end

      it 'includes the user lanugage' do
        subject[:user_language][:language].should eq(
          "abbreviation"=>"en", "name"=>"English", "population"=>238000000, "countries"=>"USA, Canada, UK, Ireland, Australia"
          )
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

        it 'includes the user lanugage' do
          subject[:user_language].should eq(
            :count      => 2,
            :language   => {'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000, "countries"=>"USA, Canada, UK, Ireland, Australia"},
            :users      => [{'id' => '1', 'lang' => 'en'}, {'id' => '3', 'lang' => 'en'}]
            )
        end

        it 'includs the foreign followers count' do
          subject[:foreign_languages_count].should eq 2
        end

        it 'returns results based on the user language' do
          subject[:foreign_languages].should == {
            'fr' => {
              count: 1,
              language: {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000, "countries"=>"France, Canada, Belgium, Switzerland"},
              users: [{'id' => '2', 'lang' => 'fr'}]
              },
              'de' => {
                count:       1,
                language:  {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000, "countries"=>"Germany, Austria, Switzerland, Belgium"},
                users:      [{'id' => '4', 'lang' => 'de'}]
              }
            }
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

          it 'includes the user lanugage' do
            subject[:user_language][:language].should eq(
              "abbreviation"=>"en", "name"=>"English", "population"=>238000000, "countries"=>"USA, Canada, UK, Ireland, Australia"
              )
          end

          it 'returns results based on the user language' do
            subject[:user_language].should == {
              :count      => 2,
              :language   => {'abbreviation'=>'en', 'name'=>'English', 'population'=>238000000, 'countries' => 'USA, Canada, UK, Ireland, Australia'},
              :users      => [{'id' => '1', 'lang' => 'en'}, {'id' => '2', 'lang' => 'en'}]
            }
          end

          it 'returns results results based on the non user language' do
            subject[:foreign_languages].should == {}
            subject[:foreign_languages_count].should eq 0
          end
        end

        context 'when no users language users' do
          let(:users) {
            [
              {'id' => '1', 'lang' => 'de'},
              {'id' => '2', 'lang' => 'fr'},
              {'id' => '3', 'lang' => 'fr'}
            ]
          }

          it 'returns a hash' do
            subject.should be_a Hash
          end

          it 'returns results based on the user language' do
            subject[:user_language].should == {
              :count      => 0,
              :language   => {"abbreviation"=>"en", "name"=>"English", "population"=>238000000, "countries"=>"USA, Canada, UK, Ireland, Australia"},
              :users      => []
            }
          end

          it 'includes the correct foreign_languages_count' do
            subject[:foreign_languages_count].should eq 3
          end

          it 'returns results results based on the non user language' do
            subject[:foreign_languages].should eq(
              'fr' => {
                :count      => 2,
                :language => { 'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000, 'countries' => 'France, Canada, Belgium, Switzerland' },
                :users => [{'id' => '2', 'lang' => 'fr'}, {'id' => '3', 'lang' => 'fr'}]
                },
                'de' => {
                  :count      => 1,
                  :language => {'abbreviation'=>'de', 'name'=>'German', 'population'=>5000000, 'countries' => 'Germany, Austria, Switzerland, Belgium' },
                  :users      => [{'id' => '1', 'lang' => 'de'}]
                }
                )
          end
        end

        context 'when aliases' do
          let(:users) {
            [
              {'id' => '1', 'lang' => 'en'},
              {'id' => '2', 'lang' => 'fr'},
              {'id' => '3', 'lang' => 'en-GB'}
            ]
          }

          it 'includes the user lanugage' do
            subject[:user_language].should == {
              :count      => 2,
              :language   => { "abbreviation"=>"en", "name"=>"English", "population"=>238000000, "countries"=>"USA, Canada, UK, Ireland, Australia" },
              :users      => [{'id' => '1', 'lang' => 'en'}, {'id' => '3', 'lang' => 'en'}]
            }
          end

          it 'includes the correct foreign_languages_count' do
            subject[:foreign_languages_count].should eq 1
          end

          it 'merges english and british' do
            subject[:foreign_languages].should eq(
              'fr' => {
                :count      => 1,
                :language   => {'abbreviation'=>'fr', 'name'=>'French', 'population'=>14000000, 'countries' => 'France, Canada, Belgium, Switzerland'},
                :users      => [{'id' => '2', 'lang' => 'fr'}]
              }
              )
          end
        end
      end
    end
  end
