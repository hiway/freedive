defmodule FreediveWeb.ClusterNodesLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Manage Nodes
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Online</.link>
        <.link href="#">Offline</.link>
      </:tabs>

      <.panel_block icon="hero-map-pin">
        fd1@trabblok
      </.panel_block>

      <.panel_block icon="hero-globe-alt">
        fd2@trabblok
      </.panel_block>

      <.panel_block icon="hero-globe-alt">
        fd3@trabblok
      </.panel_block>
    </.panel>
    """
  end
end
