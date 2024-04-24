defmodule FreediveWeb.SystemUpdatesLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Software Update
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Packages</.link>
        <.link href="#">FreeBSD</.link>
        <.link href="#">Firmware</.link>
      </:tabs>

      <.panel_block icon="hero-server">
        Update: FreeBSD 14.0-RELEASE-p7
      </.panel_block>

      <.panel_block icon="hero-cube">
        Package: Samba 4.19.6
      </.panel_block>

      <.panel_block icon="hero-cube">
        Package: Caddy 2.7.7
      </.panel_block>
    </.panel>
    """
  end
end
