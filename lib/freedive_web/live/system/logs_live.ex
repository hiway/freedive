defmodule FreediveWeb.SystemLogsLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Logs
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Errors</.link>
        <.link href="#">Warnings</.link>
      </:tabs>

      <.panel_block icon="hero-server">
        wlan0: link state changed to UP
      </.panel_block>
    </.panel>
    """
  end
end
