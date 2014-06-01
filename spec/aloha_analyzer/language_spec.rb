require 'spec_helper'

describe AlohaAnalyzer::Language do
  describe '.all' do
    it 'returns a Hash' do
      described_class.all.should be_a Hash
    end

    it 'is not empty' do
      described_class.all.should_not be_empty
    end
  end

  describe '.find_by_abbreviation' do
    subject(:language) { described_class.find_by_abbreviation(abbreviation) }
    context 'when it exits' do
      let(:abbreviation) { 'fr' }

      it 'returns a hash' do
        subject.should be_a Hash
      end

      it 'includes the total language population' do
        subject['population'].should be_a Fixnum
      end

      it 'includes the language name' do
        subject['name'].should eq 'French'
      end

      it 'includes the language abbreviation' do
        subject['abbreviation'].should eq 'fr'
      end

      it 'includes the languages countries' do
        subject['countries'].should eq 'France, Canada, Belgium, Switzerland'
      end
    end

    context 'when it does not exist' do
      let(:abbreviation) { 'esperanto' }

      it 'returns a hash' do
        subject.should be_a Hash
      end

      it 'has no population' do
        subject['population'].should be_a Fixnum
        subject['population'].should eq 0
      end

      it 'other as a name' do
        subject['name'].should eq 'Other'
      end

      it 'includes the other abbreviation' do
        subject['abbreviation'].should eq 'other'
      end

      it 'includes no countries' do
        subject['countries'].should eq ''
      end
    end
  end
end
