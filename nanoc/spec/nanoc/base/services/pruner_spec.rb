# frozen_string_literal: true

describe Nanoc::Pruner do
  subject(:pruner) { described_class.new(config, reps, dry_run: dry_run, exclude: exclude) }

  let(:config) { Nanoc::Int::Configuration.new({}).with_defaults }
  let(:dry_run) { false }
  let(:exclude) { [] }

  let(:reps) do
    Nanoc::Int::ItemRepRepo.new.tap do |reps|
      reps << Nanoc::Int::ItemRep.new(item, :default).tap do |rep|
        rep.raw_paths = { last: ['output/asdf.html'] }
      end

      reps << Nanoc::Int::ItemRep.new(item, :text).tap do |rep|
        rep.raw_paths = { last: ['output/asdf.txt'] }
      end
    end
  end

  let(:item) { Nanoc::Int::Item.new('asdf', {}, '/a.md') }

  it 'is accessible through Nanoc::Extra::Pruner' do
    expect(Nanoc::Extra::Pruner).to equal(Nanoc::Pruner)
  end

  describe '#filename_excluded?' do
    subject { pruner.filename_excluded?(filename) }

    let(:filename) { 'output/foo/bar.html' }

    context 'nothing excluded' do
      it { is_expected.to be(false) }
    end

    context 'matching identifier component excluded' do
      let(:exclude) { ['foo'] }
      it { is_expected.to be(true) }
    end

    context 'non-matching identifier component excluded' do
      let(:exclude) { ['xyz'] }
      it { is_expected.to be(false) }
    end

    context 'output dir excluded' do
      let(:exclude) { ['output'] }
      it { is_expected.to be(false) }
    end
  end

  describe '#pathname_components' do
    subject { pruner.pathname_components(pathname) }

    context 'regular path' do
      let(:pathname) { Pathname.new('/a/bb/ccc/dd/e') }
      it { is_expected.to eql(%w[/ a bb ccc dd e]) }
    end
  end

  describe '#files_and_dirs_in' do
    subject { pruner.files_and_dirs_in('output/') }

    before do
      FileUtils.mkdir_p('output/projects')
      FileUtils.mkdir_p('output/.git')

      File.write('output/asdf.html', '<p>text</p>')
      File.write('output/.htaccess', 'secret stuff here')
      File.write('output/projects/nanoc.html', '<p>Nanoc is v cool!!</p>')
      File.write('output/.git/HEAD', 'some content here')
    end

    context 'nothing excluded' do
      let(:exclude) { [] }

      it 'returns all files' do
        files = [
          'output/asdf.html',
          'output/.htaccess',
          'output/projects/nanoc.html',
          'output/.git/HEAD',
        ]
        expect(subject[0]).to match_array(files)
      end

      it 'returns all directories' do
        dirs = [
          'output/projects',
          'output/.git',
        ]
        expect(subject[1]).to match_array(dirs)
      end
    end

    context 'directory (.git) excluded' do
      let(:exclude) { ['.git'] }

      it 'returns all files' do
        files = [
          'output/asdf.html',
          'output/.htaccess',
          'output/projects/nanoc.html',
        ]
        expect(subject[0]).to match_array(files)
      end

      it 'returns all directories' do
        dirs = [
          'output/projects',
        ]
        expect(subject[1]).to match_array(dirs)
      end
    end

    context 'file (.htaccess) excluded' do
      let(:exclude) { ['.htaccess'] }

      it 'returns all files' do
        files = [
          'output/asdf.html',
          'output/projects/nanoc.html',
          'output/.git/HEAD',
        ]
        expect(subject[0]).to match_array(files)
      end

      it 'returns all directories' do
        dirs = [
          'output/projects',
          'output/.git',
        ]
        expect(subject[1]).to match_array(dirs)
      end
    end
  end
end
