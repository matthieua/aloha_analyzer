require 'spec_helper'

describe AlohaAnalyzer::Language do
  describe '.all' do
    it 'returns a Hash' do
      expect(described_class.all).to be_a Hash
    end

    it 'is not empty' do
      expect(described_class.all).not_to be_empty
    end
  end

  describe '.find_by_abbreviation' do
    subject(:language) { described_class.find_by_abbreviation(abbreviation, 'twitter') }
    context 'when it exits' do
      let(:abbreviation) { 'fr' }

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'includes the total language population' do
        expect(subject['population']).to be_a Fixnum
      end

      it 'includes the language name' do
        expect(subject['name']).to eq 'French'
      end

      it 'includes the language abbreviation' do
        expect(subject['abbreviation']).to eq 'fr'
      end

      it 'includes the languages countries' do
        expect(subject['countries']).to eq 'France, Canada, Belgium, Switzerland'
      end
    end

    context 'when it does not exist' do
      let(:abbreviation) { 'esperanto' }

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'has no population' do
        expect(subject['population']).to be_a Fixnum
        expect(subject['population']).to eq 0
      end

      it 'other as a name' do
        expect(subject['name']).to eq 'Other'
      end

      it 'includes the other abbreviation' do
        expect(subject['abbreviation']).to eq 'other'
      end

      it 'includes no countries' do
        expect(subject['countries']).to eq ''
      end
    end
  end
end
