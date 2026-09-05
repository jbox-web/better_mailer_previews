# frozen_string_literal: true

# Only Sprockets needs an explicit precompile list. A host running Propshaft
# exposes `config.assets` without a `precompile` key, and a host with no asset
# pipeline at all does not answer `config.assets` — in both cases appending here
# raises and takes the whole application down at boot.
#
# `respond_to?` is not a usable guard: `config.assets` is an OrderedOptions,
# which answers true to every message. Test the value instead.
#
app_config = Rails.application.config

if app_config.respond_to?(:assets) && app_config.assets.precompile.is_a?(Array)
  app_config.assets.precompile += %w[better_mailer_previews/application.css]
end
