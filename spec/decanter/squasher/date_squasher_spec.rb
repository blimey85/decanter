require 'spec_helper'

describe 'DateSquasher' do

  let(:squasher) { Decanter::Squasher::DateSquasher }

  describe '#squash' do
    context 'with a valid date string of default form ' do
      let(:inputs) { { year: 2016, month: 1, day: 15 } }
      it 'returns the date' do
        expect(squasher.squash('foo', inputs)).to eq Date.new(inputs[:year], inputs[:month], inputs[:day])
      end
    end
  end
end
