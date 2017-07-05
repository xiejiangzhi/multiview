RSpec.describe Multiview do
  it "has a version number" do
    expect(Multiview::VERSION).not_to be nil
  end

  it 'should create default manager' do
    expect(Multiview.manager).to be_a(Multiview::Manager)
    expect(Multiview.manager.object_id).to eql(Multiview.manager.object_id)
    expect(Multiview.manager.versions_map).to eql({})
  end

  it 'should proxy #dispatch to manager' do
    expect(Multiview.manager).to receive(:dispatch).with('a', 'b', 'c')
    Multiview.dispatch('a', 'b', 'c')
  end

  it 'should proxy #redispatch to manager' do
    expect(Multiview.manager).to receive(:redispatch).with('a', 'c', 'd')
    Multiview.redispatch('a', 'c', 'd')
  end
end
