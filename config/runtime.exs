import Config
import IP
import Freedive.ConfigUtil

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

if config_env() == :prod do
  conf = Freedive.ConfigUtil.auto_load_config!()

  config :freedive, FreediveWeb.Endpoint, server: true

  %{"app" => %{"data_path_prefix" => data_path_prefix}} = conf

  %{"database" => %{"url" => database_url, "pool_size" => pool_size}} = conf

  database_path = Path.join(data_path_prefix, database_url)

  config :freedive, Freedive.Repo,
    database: database_path,
    pool_size: pool_size

  # The secret key base is used to sign/encrypt cookies and other secrets.
  %{"phoenix" => %{"secret_key_base" => secret_key_base}} = conf

  if String.starts_with?(secret_key_base, "CHANGE") do
    raise "Please update freedive.toml with a secret key."
  end

  %{
    "http" => %{
      "enable" => http_enable,
      "port" => http_port,
      "bind" => http_bind,
      "host" => http_host
    }
  } = conf

  http_ip = IP.from_string!(http_bind)

  if http_enable do
    config :freedive, FreediveWeb.Endpoint,
      url: [host: http_host, port: http_port],
      http: [
        ip: http_ip,
        port: http_port
      ],
      secret_key_base: secret_key_base
  end

  %{
    "https" => %{
      "enable" => https_enable,
      "port" => https_port,
      "bind" => https_bind,
      "host" => https_host,
      "keyfile" => https_keyfile,
      "certfile" => https_certfile
    }
  } = conf

  if https_enable do
    https_ip = IP.from_string!(https_bind)

    config :freedive, FreediveWeb.Endpoint,
      url: [
        host: https_host,
        port: https_port
      ],
      https: [
        ip: https_ip,
        port: https_port,
        cipher_suite: :strong,
        keyfile: Path.join(data_path_prefix, https_keyfile),
        certfile: Path.join(data_path_prefix, https_certfile)
      ],
      secret_key_base: secret_key_base
  end
end
