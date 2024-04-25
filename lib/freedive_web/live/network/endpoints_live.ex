defmodule FreediveWeb.NetworkEndpointsLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Endpoints
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Enabled</.link>
        <.link href="#">Disabled</.link>
      </:tabs>
      <.panel_block icon="hero-tag">
        mastodon.sharma.io:[80, 443] (em1) => [mastodon:8000] (tailscale)
      </.panel_block>

      <.panel_block icon="hero-tag">
        example.11001000.xyz:[80, 443] (em1) => [example:8000] (tailscale)
      </.panel_block>

      <.panel_block icon="hero-tag">
        example.248163264.xyz:[80, 443] (em1) => [example:8000] (tailscale)
      </.panel_block>
    </.panel>
    """
  end
end
