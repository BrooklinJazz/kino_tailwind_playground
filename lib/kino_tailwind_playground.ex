defmodule KinoTailwindPlayground do
  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "Tailwind Playground"
  require Logger

  @impl true
  def init(attrs, ctx) do
    source = attrs["source"] || ""

    {:ok, assign(ctx, source: source),
     editor: [attribute: "html", language: "html", placement: :top]}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{source: ctx.assigns.source}, ctx}
  end

  @impl true
  def handle_event("update", %{"source" => source}, ctx) do
    broadcast_event(ctx, "update", %{"source" => source})
    Logger.info("handle update event source: #{source}")
    {:noreply, assign(ctx, source: source)}
  end

  @impl true
  def handle_event("button-clicked", _, ctx) do
    broadcast_event(ctx, "message-received", %{"message" => "Hello from backend"})
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    %{"source" => ctx.assigns.source, "ctx" => ctx}
  end

  @impl true
  def to_source(attrs) do
    broadcast_event(attrs["ctx"], "display-html", %{"html" => attrs["html"]})
    # we arent' rendering anything for now.
    ""
  end

  asset "main.js" do
    """
    export function init(ctx, payload) {
      ctx.importCSS("main.css");
      ctx
        .importJS(
          "https://cdn.tailwindcss.com?plugins=forms,typography,aspect-ratio,line-clamp"
        )
        .then(() => {

          ctx.handleEvent("display-html", ({ html }) => {
            ctx.root.innerHTML = html
          });

          ctx.handleSync(() => {
            // Synchronously invokes change listeners
            document.activeElement &&
              document.activeElement.dispatchEvent(new Event("change"));
          });
        });
    }

    """
  end
end

Kino.SmartCell.register(Kino.SmartCell.Plain)
