defmodule FlowWeb.DashboardLive do
  use FlowWeb, :live_view

  alias Flow.Fleet

  @telemetry_topic "telemetry_events"
  @alerts_topic "alerts"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Flow.PubSub, @telemetry_topic)
      Phoenix.PubSub.subscribe(Flow.PubSub, @alerts_topic)
    end

    telemetry_events = Fleet.list_recent_telemetry_events()
    alerts = Fleet.list_active_alerts()

    socket =
      socket
      |> assign(:page_title, "Flow Dashboard")
      |> assign(:current_scope, nil)
      |> stream(:telemetry_events, telemetry_events)
      |> stream(:alerts, alerts)

    {:ok, socket}
  end

  @impl true
  def handle_info({:telemetry_event, _attrs}, socket) do
    telemetry_events = Fleet.list_recent_telemetry_events()

    {:noreply, stream(socket, :telemetry_events, telemetry_events, reset: true)}
  end

  def handle_info({:alert_created, _alert}, socket) do
    alerts = Fleet.list_active_alerts()

    {:noreply, stream(socket, :alerts, alerts, reset: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="relative isolate overflow-hidden rounded-3xl border border-black/5 bg-white/70 shadow-[0_20px_60px_-30px_rgba(15,23,42,0.45)] backdrop-blur">
        <div class="absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(14,116,144,0.08),_transparent_60%)]"></div>
        <div class="absolute right-0 top-0 h-40 w-40 -translate-y-1/2 translate-x-1/3 rounded-full bg-[radial-gradient(circle,_rgba(239,68,68,0.18),_transparent_70%)]"></div>

        <div class="relative grid gap-8 px-6 py-10 sm:px-10 lg:grid-cols-[1.2fr_1fr]">
          <div class="space-y-6">
            <div class="flex items-center gap-3">
              <div class="rounded-2xl bg-slate-900 px-3 py-2">
                <.icon name="hero-bolt" class="size-5 text-white" />
              </div>
              <div>
                <p class="text-xs uppercase tracking-[0.35em] text-slate-500">Monitoramento em tempo real</p>
                <h1 class="text-2xl font-semibold text-slate-900 sm:text-3xl">Flow Telemetria</h1>
              </div>
            </div>

            <p class="max-w-xl text-base leading-7 text-slate-600">
              Visualize as ultimas leituras de telemetria e alertas criticos gerados pelo sistema. O pipeline usa
              backpressure e jobs persistentes para manter a operacao estavel mesmo em picos de carga.
            </p>

            <div class="grid gap-4 sm:grid-cols-3">
              <div class="rounded-2xl border border-slate-200 bg-white/80 p-4 shadow-sm">
                <p class="text-xs uppercase tracking-[0.25em] text-slate-500">Eventos</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900">25</p>
                <p class="mt-2 text-xs text-slate-500">Ultimas leituras exibidas</p>
              </div>
              <div class="rounded-2xl border border-slate-200 bg-white/80 p-4 shadow-sm">
                <p class="text-xs uppercase tracking-[0.25em] text-slate-500">Alertas</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900">20</p>
                <p class="mt-2 text-xs text-slate-500">Infrações em destaque</p>
              </div>
              <div class="rounded-2xl border border-slate-200 bg-white/80 p-4 shadow-sm">
                <p class="text-xs uppercase tracking-[0.25em] text-slate-500">Limite</p>
                <p class="mt-3 text-2xl font-semibold text-slate-900">80 km/h</p>
                <p class="mt-2 text-xs text-slate-500">Regra em tempo real</p>
              </div>
            </div>
          </div>

          <div class="rounded-3xl border border-slate-200 bg-slate-950 px-6 py-8 text-slate-100 shadow-lg">
            <h2 class="text-sm font-semibold uppercase tracking-[0.3em] text-slate-400">Resumo operacional</h2>
            <div class="mt-6 space-y-5 text-sm text-slate-200">
              <div class="flex items-center justify-between">
                <span class="text-slate-400">Batch</span>
                <span class="flow-mono">50 eventos / 500ms</span>
              </div>
              <div class="flex items-center justify-between">
                <span class="text-slate-400">Pipeline</span>
                <span class="flow-mono">Broadway</span>
              </div>
              <div class="flex items-center justify-between">
                <span class="text-slate-400">Jobs</span>
                <span class="flow-mono">Oban - high_priority</span>
              </div>
              <div class="flex items-center justify-between">
                <span class="text-slate-400">Persistencia</span>
                <span class="flow-mono">PostgreSQL</span>
              </div>
              <div class="rounded-2xl border border-slate-800 bg-slate-900/70 p-4">
                <p class="text-xs uppercase tracking-[0.3em] text-slate-400">Sinal vivo</p>
                <p class="mt-3 text-lg font-semibold">Atualizacao instantanea via PubSub</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-10 grid gap-6 lg:grid-cols-[2fr_1fr]">
        <section class="rounded-3xl border border-slate-200 bg-white/90 p-6 shadow-sm">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">Ultimas leituras</h2>
            <span class="rounded-full border border-slate-200 px-3 py-1 text-xs text-slate-500">
              atualizacao em tempo real
            </span>
          </div>

          <div class="mt-6 overflow-hidden rounded-2xl border border-slate-200">
            <div class="grid grid-cols-[1.4fr_1fr_1fr_1fr] gap-2 bg-slate-900 px-4 py-3 text-xs uppercase tracking-[0.2em] text-slate-300">
              <span>Veiculo</span>
              <span>Velocidade</span>
              <span>Latitude</span>
              <span>Timestamp</span>
            </div>
            <div id="telemetry-events" phx-update="stream" class="divide-y divide-slate-200">
              <div class="hidden px-4 py-6 text-sm text-slate-500 only:block">
                Nenhuma leitura registrada ainda.
              </div>
              <div
                :for={{id, event} <- @streams.telemetry_events}
                id={id}
                class="grid grid-cols-[1.4fr_1fr_1fr_1fr] gap-2 px-4 py-3 text-sm text-slate-700 transition hover:bg-slate-50"
              >
                <div class="flow-mono text-xs text-slate-500">{event.vehicle_id}</div>
                <div class="font-semibold text-slate-900">{format_speed(event.speed)} km/h</div>
                <div class="flow-mono text-xs text-slate-500">{format_coord(event.latitude)}</div>
                <div class="flow-mono text-xs text-slate-500">{format_timestamp(event.timestamp)}</div>
              </div>
            </div>
          </div>
        </section>

        <section class="rounded-3xl border border-slate-200 bg-white/90 p-6 shadow-sm">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">Alertas ativos</h2>
            <span class="rounded-full border border-slate-200 px-3 py-1 text-xs text-slate-500">
              critico
            </span>
          </div>

          <div id="alerts" phx-update="stream" class="mt-6 space-y-3">
            <div class="hidden rounded-2xl border border-dashed border-slate-200 p-4 text-sm text-slate-500 only:block">
              Nenhum alerta ativo no momento.
            </div>
            <div
              :for={{id, alert} <- @streams.alerts}
              id={id}
              class="group rounded-2xl border border-slate-200 bg-slate-50 p-4 transition hover:-translate-y-0.5 hover:border-slate-300 hover:bg-white"
            >
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-xs uppercase tracking-[0.2em] text-slate-500">{alert.type}</p>
                  <p class="mt-2 text-sm font-semibold text-slate-900">{alert.description}</p>
                </div>
                <div class="text-right text-xs text-slate-500">
                  <p class="flow-mono">{alert.vehicle_id}</p>
                  <p class="mt-2">{format_timestamp(alert.inserted_at)}</p>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp format_speed(speed) when is_number(speed) do
    speed
      |> normalize_float()
      |> Float.round(1)
    |> :erlang.float_to_binary(decimals: 1)
  end

  defp format_speed(_speed), do: "-"

  defp format_coord(value) when is_number(value) do
    value
      |> normalize_float()
      |> Float.round(4)
    |> :erlang.float_to_binary(decimals: 4)
  end

  defp format_coord(_value), do: "-"

  defp format_timestamp(%DateTime{} = timestamp) do
    Calendar.strftime(timestamp, "%d/%m/%Y %H:%M:%S")
  end

  defp format_timestamp(_timestamp), do: "-"


  defp normalize_float(value) when is_float(value), do: value
  defp normalize_float(value) when is_integer(value), do: value * 1.0
end
