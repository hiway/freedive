defmodule Freedive.Repo do
  use Ecto.Repo,
    otp_app: :freedive,
    adapter: Ecto.Adapters.SQLite3
end
