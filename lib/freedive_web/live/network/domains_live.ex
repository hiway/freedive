defmodule FreediveWeb.NetworkDomainsLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Domains
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Enabled</.link>
        <.link href="#">Disabled</.link>
      </:tabs>

      <.panel_block icon="hero-tag">
        11001000.xyz
      </.panel_block>

      <.panel_block icon="hero-tag">
        248163264.xyz
      </.panel_block>

      <.panel_block icon="hero-tag">
        sharma.io
      </.panel_block>
    </.panel>
    """
  end
end
