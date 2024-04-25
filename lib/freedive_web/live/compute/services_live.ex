defmodule FreediveWeb.ComputeServicesLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Services
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Enabled</.link>
        <.link href="#">Disabled</.link>
      </:tabs>

      <.panel_block icon="hero-puzzle-piece">
        PostgreSQL
      </.panel_block>

      <.panel_block icon="hero-puzzle-piece">
        Valkey
      </.panel_block>
    </.panel>
    """
  end
end
