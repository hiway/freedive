defmodule FreediveWeb.SystemBackupsLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Backups
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">System</.link>
        <.link href="#">Storage</.link>
        <.link href="#">Compute</.link>
      </:tabs>

      <.panel_block icon="hero-rocket-launch">
        Mastodon
      </.panel_block>

      <.panel_block icon="hero-code-bracket">
        Archive link
      </.panel_block>

      <.panel_block icon="hero-puzzle-piece">
        PostgreSQL
      </.panel_block>

      <.panel_block icon="hero-puzzle-piece">
        Valkey
      </.panel_block>

      <.panel_block icon="hero-server-stack">
        /mnt/live
      </.panel_block>

      <.panel_block icon="hero-adjustments-horizontal">
        Configuration
      </.panel_block>

      <.panel_block icon="hero-finger-print">
        Secrets
      </.panel_block>

      <.panel_block icon="hero-newspaper">
        Logs
      </.panel_block>

      <.panel_block icon="hero-squares-2x2">
        Archive bookmarks
      </.panel_block>
    </.panel>
    """
  end
end
