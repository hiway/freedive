import Config
alias PhxConfigUtil.BindToIp

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

if System.get_env("PHX_SERVER") do
  config :freedive, FreediveWeb.Endpoint, server: true
end

host = System.get_env("PHX_HOST") || "localhost"
port = String.to_integer(System.get_env("PORT") || "4000")
bind = System.get_env("BIND") || "127.0.0.1"
ip = BindToIp.parse!(bind)

if config_env() == :dev do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      "celuisz10diUmQizw1ZWXMKgp0DTjSlSraXFRqve4Vi+2AjvFYbY8YgGHV/PJ1aU"

  database_path =
    System.get_env("DATABASE_PATH") ||
      Path.expand("../freedive_dev.db", Path.dirname(__ENV__.file))

  config :freedive, FreediveWeb.Endpoint,
    http: [ip: ip, port: port],
    secret_key_base: secret_key_base

  config :freedive, Freedive.Repo,
    database: Path.expand("../#{database_path}", Path.dirname(__ENV__.file))
end

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      environment variable DATABASE_PATH is missing.
      For example: /etc/freedive/freedive.db
      """

  config :freedive, Freedive.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  config :freedive, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :freedive, FreediveWeb.Endpoint,
    url: [host: host, port: port, scheme: "https"],
    https: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: ip,
      port: port,
      cipher_suite: :strong,
      keyfile: System.get_env("TLS_KEY_PATH"),
      certfile: System.get_env("TLS_CERT_PATH")
    ],
    secret_key_base: secret_key_base

  config :freedive, mobius_dir: System.get_env("MOBIUS_DIR") || "/var/db/freedive/mobius"

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :freedive, Freedive.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
