# frozen_string_literal: true

RSpec.describe 'Basic Tasks' do
  it 'should be able to load basic tasks file' do
    expect { load File.expand_path('../algorithms/basic_tasks.rb', __dir__) }.not_to raise_error
  end

  context 'when running basic tasks methods' do
    before do
      load File.expand_path('../algorithms/basic_tasks.rb', __dir__)
    end

    it 'should calculate factorial correctly' do
      expect(factorial(5)).to eq(120)
      expect(factorial(0)).to eq(1)
    end

    it 'should greet users properly' do
      expect(greet).to eq('Hello, Guest!')
      expect(greet('Alice')).to eq('Hello, Alice!')
    end

    it 'should check even numbers correctly' do
      expect(even?(4)).to be true
      expect(even?(3)).to be false
    end

    it 'should count vowels correctly' do
      expect(count_vowels('hello')).to eq(2)
      expect(count_vowels('HELLO')).to eq(2)
    end

    it 'should check palindromes correctly' do
      expect(palindrome?('racecar')).to be true
      expect(palindrome?('hello')).to be false
    end
  end
end
