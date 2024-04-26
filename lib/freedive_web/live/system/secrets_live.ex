defmodule FreediveWeb.SystemSecretsLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Secrets
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">API</.link>
        <.link href="#">SSH</.link>
        <.link href="#">Pwnd</.link>
      </:tabs>

      <.panel_block icon="hero-key">
        Backblaze B2 AppID
      </.panel_block>

      <.panel_block icon="hero-key">
        Backblaze B2 AppKey
      </.panel_block>

      <.panel_block icon="hero-shield-exclamation" icon_class="has-text-danger" active="true">
        Telegram Bot Token
      </.panel_block>

      <.panel_block icon="hero-check-badge">
        admin@desktop
      </.panel_block>
    </.panel>

    <.box>
      <form>
        <label class="label">
          Telegram Bot Token
        </label>
        <div class="field has-addons">
          <div class="control is-expanded has-icons-left">
            <input
              class="input"
              type="text"
              placeholder="Token"
              value="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
            />
            <span class="icon is-left">
              <.icon name="hero-key" />
            </span>
          </div>

          <div class="control">
            <button class="button is-primary">Update</button>
          </div>
        </div>
      </form>
      <p>
        <.link class="has-text-danger">This secret might be exposed.</.link>
        <br />
        <.link class="text-gray-500">Learn more on Have I Been Pwned</.link>
      </p>
    </.box>
    """
  end
end
