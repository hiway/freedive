defmodule FreediveWeb.DataRemoteLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Remote Data
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Enabled</.link>
        <.link href="#">Disabled</.link>
      </:tabs>

      <.panel_block icon="hero-folder">
        B2: example_bucket
      </.panel_block>

      <.panel_block icon="hero-folder">
        B2: stuff
      </.panel_block>
    </.panel>
    """
  end
end
