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
    Process.send_after(self(), {:display_html, ctx.assigns.initial_html}, 100)
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(_ctx) do
    %{}
  end

  @impl true
  def to_source(attrs) do
    # we can't encode ctx in attrs so we send ourselves a message in order to display the html.
    send(self(), {:display_html, attrs["html"]})
    "Kino.nothing()"
  end

  @impl true
  def handle_info({:display_html, html}, ctx) do
    broadcast_event(ctx, "display-html", %{"html" => html})
    {:noreply, ctx}
  end

  asset "main.css" do
    """
    .wrapper {
      position: relative;
      width: 100%;
      height: 100%;
      overflow-x: auto;
      background-color: white;
    }

    svg {
      pointer-events: none;
    }

    .size-btn {
      color: white;
      border-radius: 8px;
      border-style: none;
      background-color: #33394c;
      width: 28px;
      height: 28px;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 4px;
    }

    .active {
      background-color: #495e7c;
    }

    .button-header {
      padding: 12px;
      background-color: #0f182a;
      display: flex;
      gap: 8px;
    }

    #iframe {
      background-color: white;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: none;
      display: block;
      margin-left: auto;
      margin-right: auto;
      overflow: auto;
    }

    #iframe-container {
      max-width: 100%;
      display: block;
      background-color: #292c34;
      height: 570px;
      resize: vertical;
      overflow: hidden;
      position: relative;
      padding: 0 5px 5px;
    }
    """
  end

  asset "main.js" do
    """
    export function init(ctx, payload) {
      ctx.importCSS("main.css");

      ctx.root.innerHTML = `
        <div class="wrapper">
          <div class="button-header">
            <button data-width="375px" class="size-btn text-sm">
              xs
            </button>
            <button data-width="640px" class="size-btn text-sm">
              sm
            </button>
            <button data-width="768px" class="size-btn text-sm">
              md
            </button>
            <button data-width="100%" class="size-btn active">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25m18 0A2.25 2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0V12a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 12V5.25" />
              </svg>
            </button>
          </div>
          <div id="iframe-container">
            <iframe id="iframe" loading="eager" width="100%" height="100%"></iframe>
          </div>
        </div>
      `
      ctx
        .importJS(
          "https://cdn.tailwindcss.com?plugins=forms,typography,aspect-ratio"
        )
        .then(() => {
          let iframe = ctx.root.querySelector("#iframe");
          let buttons = document.querySelectorAll(".size-btn");

          iframe.srcdoc = `
            <head>
              <script src='https://cdn.tailwindcss.com?plugins=forms,typography,aspect-ratio'></script>
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body id="body">
            </body>
          `
          buttons.forEach((btn) => {
            btn.addEventListener("click", (e) => {
              iframe.style.maxWidth = e.target.dataset.width;
              buttons.forEach((btn) => { btn.classList.remove("active") })
              e.target.classList.add("active")
            });
          });

          ctx.handleEvent("display-html", ({ html }) => {
            let body = iframe.contentWindow.document.querySelector("#body");
            body.innerHTML = html
          });

          ctx.pushEvent("initial-render", { });

          ctx.handleSync(() => {
            // Synchronously invokes change listeners
            document.activeElement && document.activeElement.dispatchEvent(new Event("change"));
          });
        });
    }
    """
  end
end

Kino.SmartCell.register(Kino.TailwindPlayground)
