defmodule FreediveWeb.DashboardLive do
  use Phoenix.LiveView
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)
    {:ok, socket |> assign(%{
      user_name: user_name(),
      host_name: host_name(),
      date_time: date_time(),
      uname: uname(),
      processor_arch: processor_arch(),
      freebsd_version: freebsd_version(),
      })}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    {:noreply, socket |> assign(%{
      date_time: date_time(),
      })}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def user_name() do
    {stdout, _} = System.cmd("whoami", [])
    String.trim(stdout)
  end

  def host_name() do
    {stdout, _} = System.cmd("hostname", [])
    String.trim(stdout)
  end

  def date_time() do
    {stdout, _} = System.cmd("date", [])
    String.trim(stdout)
  end

  def freebsd_version() do
    {stdout, _} = System.cmd("freebsd-version", [])
    String.trim(stdout)
  end

  def processor_arch() do
    {stdout, _} = System.cmd("uname", ["-p"])
    String.trim(stdout)
  end

  def uname() do
    {stdout, _} = System.cmd("uname", [])
    String.trim(stdout)
  end

end
