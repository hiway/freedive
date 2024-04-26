defmodule FreediveWeb.SystemAlertsLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Alerts
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Active</.link>
        <.link href="#">Resolved</.link>
        <.link href="#">Dismissed</.link>
      </:tabs>

      <.panel_block icon="hero-globe-alt">
        Network: warning - high latency (3.14s)
      </.panel_block>

      <.panel_block icon="hero-server">
        Data: error - external storage unavailable
      </.panel_block>

    </.panel>
    """
  end
end
