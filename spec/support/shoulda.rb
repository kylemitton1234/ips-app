Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Callback::Matchers::ActiveModel, type: :model
end
