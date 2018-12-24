RSpec.shared_context 'storage context', storage: nil do
  before(:each) do
    storage.flush!
  end

  after(:each) do
    storage.flush!
  end
end
