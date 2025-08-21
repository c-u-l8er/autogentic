import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :autogentic, AutogenticWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "autogentic_test_secret_key_base_that_is_at_least_64_characters_long",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
