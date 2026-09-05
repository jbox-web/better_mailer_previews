# frozen_string_literal: true

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!

  # include ActionView::TestCase::Behavior so we can access @output_buffer in view specs
  config.include ActionView::TestCase::Behavior, file_path: %r{spec/views}
end
