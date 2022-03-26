defmodule Freedive.Api.Reboot do
  alias Freedive.Api.Notification

  def reboot() do
    Notification.send("Rebooting")
    {stdout, _} = System.cmd("shutdown", ["-r", "now"])
    stdout |> String.trim()
  end
end
