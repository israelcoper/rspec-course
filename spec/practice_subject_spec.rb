RSpec.describe Hash do
  context 'implicit subject' do
    it 'verify length' do
      expect(subject.length).to eq 0

      subject[:a] = 1
      expect(subject.length).to eq 1
    end
  end


  context 'explicit subject' do
    subject { { a: 1, b: 2 } }

    it 'verify length' do
      expect(subject.length).to eq 2
    end
  end

  context 'explicit subject with name' do
    subject(:hash) { { a: 1, b: 2 } }

    it 'verify length' do
      expect(hash.length).to eq 2
    end
  end
end
