defmodule FreediveWeb.NetworkPublicLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Public Network
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Up</.link>
        <.link href="#">Down</.link>
      </:tabs>

      <.panel_block icon="hero-globe-alt">
        em1
      </.panel_block>
    </.panel>
    """
  end
end
