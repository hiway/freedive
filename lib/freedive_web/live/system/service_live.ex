defmodule FreediveWeb.SystemServicesLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        System Services
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Running</.link>
        <.link href="#">Enabled</.link>
      </:tabs>

      <.panel_block icon="hero-clock">
        NTPd
      </.panel_block>

      <.panel_block icon="hero-at-symbol">
        Sendmail
      </.panel_block>

      <.panel_block icon="hero-bolt">
        Powerd
      </.panel_block>

      <.panel_block icon="hero-globe-alt">
        Caddy
      </.panel_block>
    </.panel>
    """
  end
end
