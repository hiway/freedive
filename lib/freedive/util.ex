defmodule Freedive.ConfigUtil do
  import Toml

  def auto_load_config!() do
    path = "freedive.toml"

    if File.exists?(path) do
      Toml.decode_file!(path)
    else
      path = "/usr/local/etc/freedive.toml"

      if File.exists?(path) do
        Toml.decode_file!(path)
      else
        raise "Configuration file 'freedive.toml' not found. Expected in current directory or /usr/local/etc/"
      end
    end
  end
end
