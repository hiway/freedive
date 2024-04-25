defmodule FreediveWeb.NetworkPrivateLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Private Network
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Up</.link>
        <.link href="#">Down</.link>
      </:tabs>

      <.panel_block icon="hero-lock-closed">
        Tailscale
      </.panel_block>

      <.panel_block icon="hero-lock-closed">
        Wireguard
      </.panel_block>
    </.panel>
    """
  end
end
