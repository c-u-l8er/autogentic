defmodule AutogenticWeb.DashboardLive do
  use AutogenticWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to agent events
      Phoenix.PubSub.subscribe(Autogentic.PubSub, "agent_events")
      # Refresh data periodically
      :timer.send_interval(5000, self(), :refresh_data)
    end

    socket =
      socket
      |> assign(:page_title, "Autogentic Dashboard")
      |> assign(:system_stats, get_system_stats())
      |> assign(:active_agents, get_active_agents())
      |> assign(:recent_events, get_recent_events())
      |> assign(:reasoning_sessions, get_reasoning_sessions())
      |> assign(:learning_stats, get_learning_stats())

    {:ok, socket}
  end

  @impl true
  def handle_info(:refresh_data, socket) do
    socket =
      socket
      |> assign(:system_stats, get_system_stats())
      |> assign(:active_agents, get_active_agents())
      |> assign(:recent_events, get_recent_events())
      |> assign(:reasoning_sessions, get_reasoning_sessions())
      |> assign(:learning_stats, get_learning_stats())

    {:noreply, socket}
  end

  def handle_info({event, payload}, socket) do
    # Handle agent events
    recent_events = [
      %{
        event: event,
        payload: payload,
        timestamp: DateTime.utc_now()
      } | socket.assigns.recent_events
    ] |> Enum.take(50)

    {:noreply, assign(socket, :recent_events, recent_events)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <!-- Header -->
      <div class="bg-white shadow">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between items-center py-6">
            <div class="flex items-center">
              <h1 class="text-3xl font-bold text-gray-900">
                🤖 Autogentic v2.0 Dashboard
              </h1>
              <span class="ml-2 px-2 py-1 bg-green-100 text-green-800 text-xs font-medium rounded">
                ACTIVE
              </span>
            </div>
            <div class="flex space-x-4">
              <.link navigate={~p"/agents"} class="text-indigo-600 hover:text-indigo-500">
                View All Agents
              </.link>
              <.link navigate={~p"/demo"} class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700">
                Run Demo
              </.link>
            </div>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- System Stats -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <span class="text-2xl">🤖</span>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Active Agents
                    </dt>
                    <dd class="text-lg font-medium text-gray-900">
                      <%= length(@active_agents) %>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <span class="text-2xl">🧠</span>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Reasoning Sessions
                    </dt>
                    <dd class="text-lg font-medium text-gray-900">
                      <%= @reasoning_sessions.active %>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <span class="text-2xl">📚</span>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Learning Patterns
                    </dt>
                    <dd class="text-lg font-medium text-gray-900">
                      <%= @learning_stats.patterns_stored %>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <span class="text-2xl">⚡</span>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      System Health
                    </dt>
                    <dd class="text-lg font-medium text-green-600">
                      Excellent
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Active Agents -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div class="bg-white shadow rounded-lg">
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">Active Agents</h3>
            </div>
            <div class="p-6">
              <div class="space-y-4">
                <%= for agent <- @active_agents do %>
                  <div class="flex items-center justify-between p-3 bg-gray-50 rounded">
                    <div class="flex items-center">
                      <div class="flex-shrink-0">
                        <div class="h-2 w-2 bg-green-400 rounded-full"></div>
                      </div>
                      <div class="ml-3">
                        <p class="text-sm font-medium text-gray-900">
                          <%= agent.name %>
                        </p>
                        <p class="text-sm text-gray-500">
                          State: <%= agent.state %> | Capabilities: <%= Enum.join(agent.capabilities, ", ") %>
                        </p>
                      </div>
                    </div>
                    <div class="flex space-x-2">
                      <.link
                        navigate={~p"/agents/#{agent.name}"}
                        class="text-indigo-600 hover:text-indigo-500 text-sm"
                      >
                        View Details
                      </.link>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          </div>

          <!-- Recent Events -->
          <div class="bg-white shadow rounded-lg">
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">Recent Events</h3>
            </div>
            <div class="p-6">
              <div class="space-y-3 max-h-96 overflow-y-auto">
                <%= for event <- Enum.take(@recent_events, 10) do %>
                  <div class="flex items-start space-x-3">
                    <div class="flex-shrink-0">
                      <span class="text-sm">
                        <%= event_icon(event.event) %>
                      </span>
                    </div>
                    <div class="min-w-0 flex-1">
                      <p class="text-sm font-medium text-gray-900">
                        <%= event.event %>
                      </p>
                      <p class="text-xs text-gray-500">
                        <%= format_timestamp(event.timestamp) %>
                      </p>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        </div>

        <!-- Reasoning and Learning Stats -->
        <div class="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div class="bg-white shadow rounded-lg">
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">Reasoning Activity</h3>
            </div>
            <div class="p-6">
              <div class="space-y-4">
                <div class="flex justify-between">
                  <span class="text-sm text-gray-500">Active Sessions:</span>
                  <span class="text-sm font-medium"><%= @reasoning_sessions.active %></span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-500">Completed Today:</span>
                  <span class="text-sm font-medium"><%= @reasoning_sessions.completed_today %></span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-500">Avg Confidence:</span>
                  <span class="text-sm font-medium"><%= @reasoning_sessions.avg_confidence %>%</span>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white shadow rounded-lg">
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">Learning Progress</h3>
            </div>
            <div class="p-6">
              <div class="space-y-4">
                <div class="flex justify-between">
                  <span class="text-sm text-gray-500">Patterns Stored:</span>
                  <span class="text-sm font-medium"><%= @learning_stats.patterns_stored %></span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-500">Insights Shared:</span>
                  <span class="text-sm font-medium"><%= @learning_stats.insights_shared %></span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-500">Adaptations Applied:</span>
                  <span class="text-sm font-medium"><%= @learning_stats.adaptations %></span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Helper functions

  defp get_system_stats do
    %{
      uptime: "2h 34m",
      memory_usage: "156 MB",
      cpu_usage: "12%",
      active_connections: 8
    }
  end

  defp get_active_agents do
    [
      %{
        name: :deployment_planner,
        state: :idle,
        capabilities: [:planning, :risk_assessment],
        uptime: "2h 30m"
      },
      %{
        name: :security_agent,
        state: :monitoring,
        capabilities: [:security_analysis, :threat_detection],
        uptime: "2h 30m"
      },
      %{
        name: :executor_agent,
        state: :ready,
        capabilities: [:execution, :monitoring],
        uptime: "2h 29m"
      },
      %{
        name: :monitor_agent,
        state: :observing,
        capabilities: [:monitoring, :alerting],
        uptime: "2h 29m"
      }
    ]
  end

  defp get_recent_events do
    [
      %{
        event: :agent_started,
        payload: %{agent: :monitor_agent},
        timestamp: DateTime.add(DateTime.utc_now(), -300)
      },
      %{
        event: :reasoning_session_complete,
        payload: %{session_id: "session_123", confidence: 0.85},
        timestamp: DateTime.add(DateTime.utc_now(), -600)
      }
    ]
  end

  defp get_reasoning_sessions do
    %{
      active: 2,
      completed_today: 15,
      avg_confidence: 78
    }
  end

  defp get_learning_stats do
    %{
      patterns_stored: 42,
      insights_shared: 18,
      adaptations: 7
    }
  end

  defp event_icon(:agent_started), do: "🚀"
  defp event_icon(:reasoning_session_complete), do: "🧠"
  defp event_icon(:learning_pattern_stored), do: "📚"
  defp event_icon(:coordination_complete), do: "🤝"
  defp event_icon(_), do: "⚡"

  defp format_timestamp(timestamp) do
    DateTime.to_string(timestamp)
    |> String.slice(0, 19)
    |> String.replace("T", " ")
  end
end
