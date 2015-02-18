describe RunLoop::Shasum do

  describe '.shasum' do
    it 'returns nil if path does not exist' do
      path = '/does/not/exist'
      expect(RunLoop::Shasum.shasum(path)).to be == nil
    end

    describe 'files' do
      before(:each) { expect(RunLoop::Environment).to receive(:debug?).and_return(true) }
      let(:path) { File.join(Resources.shared.app_bundle_path_i386, 'chou') }

      it 'returns nil when shasum exits non-zero' do
        allow_any_instance_of(Process::Status).to receive(:exitstatus).and_return(1)
        expect(RunLoop::Shasum.shasum(path)).to be == nil
      end

      it 'returns shasum' do
        expect(RunLoop::Shasum.shasum(path)).to be == '1689c970b48d9bfdb3d977b18bf5078d70f185fd'
      end
    end

    describe 'directories' do
      before(:each) { expect(RunLoop::Environment).to receive(:debug?).and_return(true) }
      let(:path) { Resources.shared.app_bundle_path_i386 }

      it 'returns nil when pipe exists non-zero' do
        allow_any_instance_of(Process::Status).to receive(:exitstatus).and_return(1)
        expect(RunLoop::Shasum.shasum(path)).to be == nil
      end

      it 'returns shasum for directories' do
        expect(RunLoop::Shasum.shasum(path)).to be == '34cf6501e4933d8c838a6dd15245f19dde13cc1a'
      end
    end
  end
end
