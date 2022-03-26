defmodule FreediveWeb.RebootLive do
  use Phoenix.LiveView
  alias Phoenix.LiveView.JS
  alias Freedive.Api.Reboot
  alias Freedive.Api.BE

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(%{
      confirm: :false,
      rebooting: false,
      be_current: BE.be_current(),
      be_default: BE.be_default(),
      be_temporary: BE.be_temporary(),
      host_name: host_name(),
      uptime: uptime(),
      })}
  end

  def handle_info(:remove_confirm_prompt, socket) do
    {:noreply, socket |> assign(%{confirm: :false})}
  end

  def handle_event("reboot", %{"value" => ""}, socket) do
    if connected?(socket), do: Process.send_after(self(), :remove_confirm_prompt, 5000)
    {:noreply, socket |> assign(%{confirm: :true})}
  end

  def handle_event("confirm_reboot", %{"value" => ""}, socket) do
    Reboot.reboot()
    {:noreply, socket |> assign(%{rebooting: true})}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def uptime() do
    {stdout, _} = System.cmd("uptime", [])
    String.trim(stdout)
  end

  def host_name() do
    {stdout, _} = System.cmd("hostname", [])
    String.trim(stdout)
  end

end
