import Config
import IP

defmodule BindToIp do
  def get_ip(bind) do
    case bind do
      "tailscale4" -> get_tailscale_ip4() |> verify_tailscale_is_up()
      "tailscale6" -> get_tailscale_ip6() |> verify_tailscale_is_up()
      "local4" -> IP.from_string!("127.0.0.1")
      "local6" -> IP.from_string!("0.0.0.0.0.0.0.0")
      "all4" -> IP.from_string!("0.0.0.0")
      "all6" -> IP.from_string!("::")
      other -> IP.from_string!(other)
    end
  end

  defp get_tailscale_ip4() do
    exec_tailscale(["ip", "-4"])
  end

  defp get_tailscale_ip6() do
    exec_tailscale(["ip", "-6"])
  end

  defp verify_tailscale_is_up(ip) do
    case System.cmd("tailscale", ["status"]) do
      {_, 0} -> ip
      {_, _} -> raise "Tailscale is not running"
    end
  end

  defp exec_tailscale(args) do
    case System.cmd("tailscale", args) do
      {ip, 0} -> IP.from_string!(String.trim(ip))
      {_, _} -> raise "Failed to get IP from tailscale"
    end
  end
end

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/freedive start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :freedive, FreediveWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      environment variable DATABASE_PATH is missing.
      For example: /etc/freedive/freedive.db
      """

  config :freedive, Freedive.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "localhost"
  port = String.to_integer(System.get_env("PORT") || "4000")
  bind = System.get_env("BIND") || "127.0.0.1"
  ip = BindToIp.get_ip(bind)

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
