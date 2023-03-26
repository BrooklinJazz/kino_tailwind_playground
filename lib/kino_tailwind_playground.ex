defmodule Kino.TailwindPlayground do
  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "Tailwind Playground"
  require Logger

  @impl true
  def init(attrs, ctx) do
    {:ok, assign(ctx, initial_html: attrs["html"] || ""),
     editor: [attribute: "html", language: "html", placement: :top]}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{}, ctx}
  end

  @impl true
  def handle_event("initial-render", %{}, ctx) do
    send(self(), {:display_html, ctx.assigns.initial_html})
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    %{}
  end

  @impl true
  def to_source(attrs) do
    # we can't encode ctx in attrs so we send ourselves a message in order to display the html.
    send(self(), {:display_html, attrs["html"]})
    "Kino.nothing()"
  end

  def handle_info({:display_html, html}, ctx) do
    broadcast_event(ctx, "display-html", %{"html" => html})
    {:noreply, ctx}
  end

  asset "main.js" do
    """
    export function init(ctx, payload) {
      ctx.importCSS("main.css");

      ctx.root.innerHTML = `
        <div style="width: 100%; height: 100%; border-right: groove; border-color: rgb(176 224 225 / 20%); overflow: hidden; resize: horizontal">
          <iframe id="iframe" style="width: 100%; border: 0" />
        </div>
      `
      ctx
        .importJS(
          "https://cdn.tailwindcss.com?plugins=forms,typography,aspect-ratio,line-clamp"
        )
        .then(() => {

          let iframe = ctx.root.querySelector("#iframe");

          iframe.srcdoc = `
            <head>
              <script src='https://cdn.tailwindcss.com?plugins=forms,typography,aspect-ratio,line-clamp'></script>
            </head>
            <body>
              <div id="wrapper"></div>
            </body>
          `

          ctx.handleEvent("display-html", ({ html }) => {
            let wrapper = iframe.contentWindow.document.querySelector("#wrapper");
            wrapper.innerHTML = html
            iframe.height = iframe.contentWindow.document.body.scrollHeight;
          });

          ctx.pushEvent("initial-render", { });

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

Kino.SmartCell.register(Kino.TailwindPlayground)
