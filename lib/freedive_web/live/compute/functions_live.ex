defmodule FreediveWeb.ComputeFunctionsLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Functions
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Enabled</.link>
        <.link href="#">Disabled</.link>
      </:tabs>

      <.panel_block icon="hero-code-bracket">
        Fetch Mastodon bookmarks
      </.panel_block>

      <.panel_block icon="hero-code-bracket">
        Extract links
      </.panel_block>

      <.panel_block icon="hero-code-bracket">
        Archive link
      </.panel_block>
    </.panel>
    """
  end
end
