import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :el_todo_api, ElTodoApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "QDfrZGbsbFiv0C02rNmC07vGHDrraTBxzCiPnSaoMPnVsjVYU/Erp4y5ZHktHxzZ",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
