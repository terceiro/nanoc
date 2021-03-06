# frozen_string_literal: true

describe Nanoc::Int::OutdatednessStore do
  subject(:store) { described_class.new(config: config) }

  let(:item) { Nanoc::Int::Item.new('foo', {}, '/foo.md') }
  let(:rep) { Nanoc::Int::ItemRep.new(item, :foo) }

  let(:config) { Nanoc::Int::Configuration.new.with_defaults }
  let(:items) { [] }
  let(:layouts) { [] }
  let(:code_snippets) { [] }

  describe '#include?, #add and #remove' do
    subject { store.include?(rep) }

    context 'nothing added' do
      it { is_expected.not_to be }
    end

    context 'rep added' do
      before { store.add(rep) }
      it { is_expected.to be }
    end

    context 'rep added and removed' do
      before do
        store.add(rep)
        store.remove(rep)
      end

      it { is_expected.not_to be }
    end

    context 'rep added, removed, and added again' do
      before do
        store.add(rep)
        store.remove(rep)
        store.add(rep)
      end

      it { is_expected.to be }
    end
  end

  describe 'reloading' do
    subject do
      store.store
      store.load
      store.include?(rep)
    end

    context 'not added' do
      it { is_expected.not_to be }
    end

    context 'added' do
      before { store.add(rep) }
      it { is_expected.to be }
    end
  end
end
