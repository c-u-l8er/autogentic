defmodule Autogentic.Learning.Coordinator do
  @moduledoc """
  Advanced learning coordination system that manages knowledge sharing,
  performance tracking, and adaptive behavior evolution across all agents.

  This coordinator enables continuous learning and adaptation by:
  - Tracking agent performance over time
  - Facilitating cross-agent knowledge sharing
  - Identifying and storing successful patterns
  - Providing adaptive behavior recommendations
  """

  use GenServer
  require Logger

  # State structure
  defstruct [
    :agent_performances,
    :learning_patterns,
    :knowledge_graphs,
    :adaptation_strategies,
    :cross_agent_insights,
    :performance_trends
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def record_agent_performance(agent_id, performance_data) do
    GenServer.cast(__MODULE__, {:record_performance, agent_id, performance_data})
  end

  def learn_from_outcome(agent_id, task_type, outcome_data) do
    GenServer.cast(__MODULE__, {:learn_outcome, agent_id, task_type, outcome_data})
  end

  def share_learning_insight(from_agent, insight_data) do
    GenServer.cast(__MODULE__, {:share_insight, from_agent, insight_data})
  end

  def request_adaptation_strategy(agent_id, current_performance, context) do
    GenServer.call(__MODULE__, {:request_adaptation, agent_id, current_performance, context})
  end

  def get_cross_agent_insights(query_context) do
    GenServer.call(__MODULE__, {:get_insights, query_context})
  end

  def analyze_system_learning_trends() do
    GenServer.call(__MODULE__, :analyze_trends)
  end

  # GenServer Callbacks

  def init(_opts) do
    state = %__MODULE__{
      agent_performances: %{},
      learning_patterns: %{},
      knowledge_graphs: %{},
      adaptation_strategies: initialize_adaptation_strategies(),
      cross_agent_insights: [],
      performance_trends: %{}
    }

    Logger.info("🎓 Autogentic v2.0 Learning Coordinator started")
    {:ok, state}
  end

  def handle_cast({:record_performance, agent_id, performance_data}, state) do
    updated_performances = update_agent_performance(state.agent_performances, agent_id, performance_data)
    updated_trends = update_performance_trends(state.performance_trends, agent_id, performance_data)

    updated_state = %{state |
      agent_performances: updated_performances,
      performance_trends: updated_trends
    }

    # Trigger adaptation if performance is declining
    if performance_declining?(agent_id, updated_trends) do
      trigger_performance_analysis(agent_id, performance_data)
    end

    Logger.debug("📊 Recorded performance for agent #{agent_id}")
    {:noreply, updated_state}
  end

  def handle_cast({:learn_outcome, agent_id, task_type, outcome_data}, state) do
    learning_pattern = extract_learning_pattern(agent_id, task_type, outcome_data)
    updated_patterns = store_learning_pattern(state.learning_patterns, learning_pattern)

    updated_state = %{state | learning_patterns: updated_patterns}

    # Share significant learnings with other agents
    if learning_pattern.significance >= 0.7 do
      broadcast_learning_to_relevant_agents(learning_pattern)
    end

    Logger.info("🧠 Agent #{agent_id} learned from #{task_type}: #{learning_pattern.key_insight}")
    {:noreply, updated_state}
  end

  def handle_cast({:share_insight, from_agent, insight_data}, state) do
    validated_insight = validate_insight(insight_data, from_agent)

    updated_insights = case validated_insight do
      {:valid, insight} ->
        [insight | state.cross_agent_insights] |> Enum.take(1000)  # Keep recent insights
      {:invalid, reason} ->
        Logger.warning("Invalid insight from #{from_agent}: #{reason}")
        state.cross_agent_insights
    end

    updated_state = %{state | cross_agent_insights: updated_insights}

    Logger.debug("🔗 Shared insight from agent #{from_agent}")
    {:noreply, updated_state}
  end

  def handle_call({:request_adaptation, agent_id, current_performance, context}, _from, state) do
    # Analyze current performance against historical data
    performance_analysis = analyze_agent_performance(agent_id, current_performance, state.agent_performances)

    # Find relevant adaptation strategies
    relevant_strategies = find_relevant_strategies(
      agent_id,
      performance_analysis,
      context,
      state.adaptation_strategies
    )

    # Generate personalized adaptation recommendation
    adaptation_plan = generate_adaptation_plan(
      agent_id,
      performance_analysis,
      relevant_strategies,
      context
    )

    Logger.info("🔄 Generated adaptation plan for agent #{agent_id}: #{adaptation_plan.strategy_type}")
    {:reply, {:ok, adaptation_plan}, state}
  end

  def handle_call({:get_insights, query_context}, _from, state) do
    relevant_insights = filter_relevant_insights(state.cross_agent_insights, query_context)

    combined_insights = %{
      cross_agent_insights: relevant_insights,
      insight_count: length(relevant_insights),
      query_context: query_context
    }

    {:reply, {:ok, combined_insights}, state}
  end

  def handle_call(:analyze_trends, _from, state) do
    trend_analysis = %{
      agent_performance_trends: analyze_agent_performance_trends(state.performance_trends),
      learning_pattern_evolution: analyze_learning_pattern_evolution(state.learning_patterns),
      cross_agent_collaboration: analyze_collaboration_patterns(state.cross_agent_insights),
      system_wide_improvements: identify_system_improvements(state)
    }

    Logger.info("📈 Analyzed system-wide learning trends: #{map_size(trend_analysis)} categories")
    {:reply, {:ok, trend_analysis}, state}
  end

  # Core learning implementation (simplified)

  defp update_agent_performance(performances, agent_id, performance_data) do
    agent_history = Map.get(performances, agent_id, [])
    updated_history = [add_timestamp(performance_data) | agent_history] |> Enum.take(100)
    Map.put(performances, agent_id, updated_history)
  end

  defp add_timestamp(performance_data) do
    Map.put(performance_data, :timestamp, DateTime.utc_now())
  end

  defp update_performance_trends(trends, agent_id, performance_data) do
    current_trend = Map.get(trends, agent_id, %{moving_average: 0.5, trend_direction: :stable})

    new_score = extract_performance_score(performance_data)
    updated_average = (current_trend.moving_average * 0.8) + (new_score * 0.2)

    trend_direction = determine_trend_direction(current_trend.moving_average, updated_average)

    Map.put(trends, agent_id, %{
      moving_average: updated_average,
      trend_direction: trend_direction,
      last_updated: DateTime.utc_now(),
      sample_count: Map.get(current_trend, :sample_count, 0) + 1
    })
  end

  defp extract_performance_score(performance_data) do
    cond do
      Map.has_key?(performance_data, :success_rate) -> performance_data.success_rate
      Map.has_key?(performance_data, :confidence) -> performance_data.confidence
      Map.has_key?(performance_data, :quality_score) -> performance_data.quality_score
      true -> 0.5  # Default neutral score
    end
  end

  defp determine_trend_direction(old_average, new_average) do
    diff = new_average - old_average
    threshold = 0.05

    cond do
      diff > threshold -> :improving
      diff < -threshold -> :declining
      true -> :stable
    end
  end

  defp performance_declining?(agent_id, trends) do
    case Map.get(trends, agent_id) do
      %{trend_direction: :declining, moving_average: avg} when avg < 0.6 -> true
      _ -> false
    end
  end

  defp trigger_performance_analysis(agent_id, _performance_data) do
    Task.start(fn ->
      Logger.warning("📉 Performance declining for agent #{agent_id}, triggering analysis")
      # In a full implementation, this would trigger detailed analysis and interventions
    end)
  end

  defp extract_learning_pattern(agent_id, task_type, outcome_data) do
    success = determine_outcome_success(outcome_data)
    key_factors = extract_key_factors_from_outcome(outcome_data)

    %{
      agent_id: agent_id,
      task_type: task_type,
      success: success,
      key_factors: key_factors,
      key_insight: generate_key_insight(task_type, outcome_data, success),
      significance: calculate_learning_significance(outcome_data, success),
      timestamp: DateTime.utc_now()
    }
  end

  defp determine_outcome_success(outcome_data) do
    cond do
      Map.has_key?(outcome_data, :success) -> outcome_data.success
      Map.has_key?(outcome_data, :error) -> false
      Map.get(outcome_data, :confidence, 0) >= 0.7 -> true
      true -> false
    end
  end

  defp extract_key_factors_from_outcome(outcome_data) do
    factors = []

    factors = if Map.has_key?(outcome_data, :context) do
      context_factors = Map.keys(outcome_data.context) |> Enum.take(3)
      factors ++ context_factors
    else
      factors
    end

    factors |> Enum.uniq() |> Enum.take(5)
  end

  defp generate_key_insight(task_type, outcome_data, success) do
    if success do
      case task_type do
        :coordination -> "Successful coordination achieved"
        :reasoning -> "Effective reasoning with confidence #{Map.get(outcome_data, :confidence, "unknown")}"
        :planning -> "Planning succeeded"
        _ -> "Task #{task_type} completed successfully"
      end
    else
      failure_reason = Map.get(outcome_data, :error_reason, "unknown reason")
      "Task #{task_type} failed due to: #{failure_reason}"
    end
  end

  defp calculate_learning_significance(outcome_data, success) do
    base_significance = if success, do: 0.6, else: 0.7  # Failures often more significant

    # Simple significance calculation
    total_significance = base_significance +
      (if Map.get(outcome_data, :novelty, false), do: 0.2, else: 0.0)

    min(total_significance, 1.0)
  end

  defp store_learning_pattern(patterns, learning_pattern) do
    pattern_key = {learning_pattern.agent_id, learning_pattern.task_type}
    agent_task_patterns = Map.get(patterns, pattern_key, [])
    updated_patterns = [learning_pattern | agent_task_patterns] |> Enum.take(50)
    Map.put(patterns, pattern_key, updated_patterns)
  end

  defp broadcast_learning_to_relevant_agents(learning_pattern) do
    # Identify agents who might benefit from this learning
    relevant_agents = identify_relevant_agents_for_learning(learning_pattern)

    Enum.each(relevant_agents, fn agent_id ->
      Logger.debug("📡 Broadcasting learning insight to agent #{agent_id}")
      # In a full implementation, would actually send to the agent
    end)
  end

  defp identify_relevant_agents_for_learning(_learning_pattern) do
    # Simple heuristic - in practice would use more sophisticated matching
    [:deployment_planner, :security_agent, :executor_agent, :monitor_agent]
  end

  defp validate_insight(insight_data, from_agent) do
    required_fields = [:type, :key_insight, :timestamp]

    missing_fields = Enum.filter(required_fields, fn field ->
      not Map.has_key?(insight_data, field)
    end)

    if length(missing_fields) > 0 do
      {:invalid, "Missing required fields: #{inspect(missing_fields)}"}
    else
      validated_insight = Map.put(insight_data, :source_agent, from_agent)
      {:valid, validated_insight}
    end
  end

  defp analyze_agent_performance(agent_id, current_performance, historical_performances) do
    agent_history = Map.get(historical_performances, agent_id, [])

    if length(agent_history) < 3 do
      %{
        analysis_type: :insufficient_data,
        recommendation: "Need more historical data for analysis",
        confidence: 0.3
      }
    else
      current_score = extract_performance_score(current_performance)
      historical_scores = Enum.map(agent_history, &extract_performance_score/1)
      historical_average = Enum.sum(historical_scores) / length(historical_scores)

      trend = cond do
        current_score > historical_average + 0.1 -> :improving
        current_score < historical_average - 0.1 -> :declining
        true -> :stable
      end

      %{
        analysis_type: :trend_analysis,
        current_score: current_score,
        historical_average: historical_average,
        trend: trend,
        confidence: min(length(historical_scores) / 10, 1.0)
      }
    end
  end

  defp find_relevant_strategies(_agent_id, performance_analysis, _context, adaptation_strategies) do
    # Simple strategy selection based on performance trend
    case performance_analysis.trend do
      :declining -> Map.get(adaptation_strategies, :performance_recovery, [])
      :improving -> Map.get(adaptation_strategies, :performance_enhancement, [])
      :stable -> Map.get(adaptation_strategies, :optimization, [])
    end
  end

  defp generate_adaptation_plan(agent_id, performance_analysis, strategies, _context) do
    primary_strategy = Enum.at(strategies, 0, default_strategy(:recovery))

    %{
      agent_id: agent_id,
      strategy_type: primary_strategy.type,
      specific_actions: primary_strategy.actions,
      expected_improvement: estimate_improvement_potential(performance_analysis),
      confidence: performance_analysis.confidence,
      created_at: DateTime.utc_now()
    }
  end

  defp default_strategy(type) do
    case type do
      :recovery -> %{
        type: :recovery,
        actions: ["Review recent failures", "Adjust parameters"]
      }
      :optimization -> %{
        type: :optimization,
        actions: ["Fine-tune parameters", "Optimize patterns"]
      }
      _ -> %{
        type: :general,
        actions: ["Continue monitoring", "Gradual improvements"]
      }
    end
  end

  defp estimate_improvement_potential(performance_analysis) do
    case performance_analysis.trend do
      :declining -> 0.3
      :stable -> 0.15
      :improving -> 0.1
    end
  end

  defp filter_relevant_insights(insights, _query_context) do
    # Simple filtering - in practice would use semantic matching
    Enum.take(insights, 10)
  end

  defp initialize_adaptation_strategies do
    %{
      performance_recovery: [
        %{type: :recovery, actions: ["Identify bottlenecks", "Reset parameters"]},
      ],
      performance_enhancement: [
        %{type: :enhancement, actions: ["Explore advanced techniques"]},
      ],
      optimization: [
        %{type: :optimization, actions: ["Fine-tune existing patterns"]},
      ]
    }
  end

  # Analysis functions (simplified implementations)

  defp analyze_agent_performance_trends(performance_trends) do
    Enum.map(performance_trends, fn {agent_id, trend_data} ->
      {agent_id, %{
        current_trend: trend_data.trend_direction,
        moving_average: trend_data.moving_average,
        recommendation: generate_trend_recommendation(trend_data)
      }}
    end)
    |> Enum.into(%{})
  end

  defp generate_trend_recommendation(trend_data) do
    case {trend_data.trend_direction, trend_data.moving_average} do
      {:declining, avg} when avg < 0.5 -> "Immediate intervention recommended"
      {:declining, _} -> "Monitor closely and consider optimization"
      {:improving, _} -> "Continue current improvements"
      {:stable, _} -> "Performance stable - consider enhancement"
    end
  end

  defp analyze_learning_pattern_evolution(_learning_patterns) do
    %{
      recent_learning_activity: :moderate,
      learning_velocity: :steady,
      pattern_diversity: :good
    }
  end

  defp analyze_collaboration_patterns(insights) do
    recent_insights = Enum.filter(insights, &insight_is_recent?(&1, 7 * 24 * 60 * 60))

    %{
      recent_insight_sharing: length(recent_insights),
      collaboration_quality: :good,
      active_collaborators: count_unique_sources(recent_insights)
    }
  end

  defp insight_is_recent?(insight, max_age_seconds) do
    case Map.get(insight, :timestamp) do
      nil -> false
      timestamp ->
        age_seconds = DateTime.diff(DateTime.utc_now(), timestamp)
        age_seconds <= max_age_seconds
    end
  end

  defp count_unique_sources(insights) do
    insights
    |> Enum.map(&Map.get(&1, :source_agent))
    |> Enum.uniq()
    |> length()
  end

  defp identify_system_improvements(state) do
    improvements = []

    # Check for performance issues
    declining_agents = state.performance_trends
    |> Enum.filter(fn {_agent_id, trend} -> trend.trend_direction == :declining end)
    |> Enum.map(fn {agent_id, _trend} -> agent_id end)

    improvements = if length(declining_agents) > 0 do
      ["Address performance decline in agents: #{inspect(declining_agents)}" | improvements]
    else
      improvements
    end

    if length(improvements) == 0 do
      ["System operating well - consider advanced optimization"]
    else
      improvements
    end
  end
end
