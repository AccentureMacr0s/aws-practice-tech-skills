# frozen_string_literal: true

require_relative '../lib/bundler_root_check'

RSpec.describe BundlerRootCheck do
  describe '.running_as_root?' do
    it 'returns false when not running as root' do
      # In the test environment, we're typically not running as root
      expect(described_class.running_as_root?).to be false unless Process.uid.zero?
    end

    it 'returns true when running as root' do
      # This test will only pass if run as root
      expect(described_class.running_as_root?).to be true if Process.uid.zero?
    end

    it 'checks Process.uid for root status' do
      allow(Process).to receive(:uid).and_return(0)
      expect(described_class.running_as_root?).to be true

      allow(Process).to receive(:uid).and_return(1000)
      expect(described_class.running_as_root?).to be false
    end
  end

  describe '.enforce!' do
    context 'when not running as root' do
      before do
        allow(Process).to receive(:uid).and_return(1000)
      end

      it 'does not raise an error' do
        expect { described_class.enforce! }.not_to raise_error
      end
    end

    context 'when running as root' do
      before do
        allow(Process).to receive(:uid).and_return(0)
      end

      it 'raises RootExecutionError' do
        expect { described_class.enforce! }.to raise_error(BundlerRootCheck::RootExecutionError)
      end

      it 'includes helpful error message' do
        expect { described_class.enforce! }.to raise_error do |error|
          expect(error.message).to include('Running Bundler as root is not recommended')
          expect(error.message).to include('security risk')
          expect(error.message).to include('vendor/bundle')
        end
      end
    end
  end

  describe '.warn_if_root' do
    context 'when not running as root' do
      before do
        allow(Process).to receive(:uid).and_return(1000)
      end

      it 'does not output a warning' do
        expect { described_class.warn_if_root }.not_to output.to_stderr
      end
    end

    context 'when running as root' do
      before do
        allow(Process).to receive(:uid).and_return(0)
      end

      it 'outputs a warning to stderr' do
        expect { described_class.warn_if_root }.to output(/Warning: Running Bundler as root/).to_stderr
      end

      it 'includes security warning in message' do
        expect { described_class.warn_if_root }.to output(/security risk/).to_stderr
      end
    end
  end
end
