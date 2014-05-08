require 'spec_helper'

describe AlohaAnalyzer::Language do
  describe '.all' do
    it 'returns an array' do
      described_class.all.should be_a Array
    end

    it 'is not empty' do
      described_class.all.should be_a Array
    end
  end

  describe '.total' do
    it 'returns the total number of language users' do
      total = 0
      described_class.all.each do |language|
        total += language['population']
      end
      total.should eq described_class.total
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

      it 'includes the languages coutnries' do
        subject['countries'].should eq 'France, Canada, Belgium, Switzerland'
      end
    end

    context 'when it does not exist' do
      let(:abbreviation) { 'esperanto' }

      it 'raises an exception' do
        expect { subject }.to raise_error
      end
    end
  end
end
