defmodule FreediveWeb.NetworkLocalLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Local Network
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Up</.link>
        <.link href="#">Down</.link>
      </:tabs>

      <.panel_block icon="hero-wifi">
        wlan0
      </.panel_block>

      <.panel_block icon="hero-globe-alt">
        em0
      </.panel_block>

      <.panel_block icon="hero-home">
        lo0
      </.panel_block>

      <.panel_block icon="hero-building-office">
        bastille0
      </.panel_block>
    </.panel>
    """
  end
end
