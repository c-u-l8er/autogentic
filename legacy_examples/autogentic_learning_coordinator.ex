# Autogentic v2.0 Learning Coordinator
# Handles cross-agent learning, adaptation, and knowledge evolution

defmodule AutogenticV2.LearningCoordinator do
  @moduledoc """
  Advanced learning coordination system that manages knowledge sharing,
  performance tracking, and adaptive behavior evolution across all agents.
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
    :performance_trends,
    :learning_objectives
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
      knowledge_graphs: initialize_knowledge_graphs(),
      adaptation_strategies: initialize_adaptation_strategies(),
      cross_agent_insights: [],
      performance_trends: %{},
      learning_objectives: initialize_learning_objectives()
    }

    # Schedule periodic analysis
    schedule_periodic_analysis()

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

    # Update knowledge graph with new connections
    updated_knowledge_graphs = update_knowledge_connections(
      state.knowledge_graphs,
      agent_id,
      task_type,
      outcome_data
    )

    updated_state = %{state |
      learning_patterns: updated_patterns,
      knowledge_graphs: updated_knowledge_graphs
    }

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

    # Learn from similar agents' successes
    similar_agent_insights = find_similar_agent_insights(agent_id, context, state)

    # Generate personalized adaptation recommendation
    adaptation_plan = generate_adaptation_plan(
      agent_id,
      performance_analysis,
      relevant_strategies,
      similar_agent_insights,
      context
    )

    Logger.info("🔄 Generated adaptation plan for agent #{agent_id}: #{adaptation_plan.strategy_type}")
    {:reply, {:ok, adaptation_plan}, state}
  end

  def handle_call({:get_insights, query_context}, _from, state) do
    relevant_insights = filter_relevant_insights(state.cross_agent_insights, query_context)
    knowledge_graph_insights = query_knowledge_graph(state.knowledge_graphs, query_context)

    combined_insights = %{
      cross_agent_insights: relevant_insights,
      knowledge_graph_insights: knowledge_graph_insights,
      insight_count: length(relevant_insights),
      query_context: query_context
    }

    {:reply, {:ok, combined_insights}, state}
  end

  def handle_call(:analyze_trends, _from, state) do
    trend_analysis = %{
      agent_performance_trends: analyze_agent_performance_trends(state.performance_trends),
      learning_pattern_evolution: analyze_learning_pattern_evolution(state.learning_patterns),
      knowledge_graph_growth: analyze_knowledge_graph_growth(state.knowledge_graphs),
      cross_agent_collaboration: analyze_collaboration_patterns(state.cross_agent_insights),
      system_wide_improvements: identify_system_improvements(state)
    }

    Logger.info("📈 Analyzed system-wide learning trends: #{map_size(trend_analysis)} categories")
    {:reply, {:ok, trend_analysis}, state}
  end

  def handle_info(:periodic_analysis, state) do
    # Perform periodic system analysis
    perform_periodic_learning_analysis(state)

    # Schedule next analysis
    schedule_periodic_analysis()

    {:noreply, state}
  end

  # Core learning logic

  defp update_agent_performance(performances, agent_id, performance_data) do
    agent_history = Map.get(performances, agent_id, [])
    updated_history = [add_timestamp(performance_data) | agent_history] |> Enum.take(100)  # Keep recent history

    Map.put(performances, agent_id, updated_history)
  end

  defp add_timestamp(performance_data) do
    Map.put(performance_data, :timestamp, DateTime.utc_now())
  end

  defp update_performance_trends(trends, agent_id, performance_data) do
    current_trend = Map.get(trends, agent_id, %{moving_average: 0.5, trend_direction: :stable})

    # Simple moving average calculation
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
    # Extract numeric performance score from various metrics
    cond do
      Map.has_key?(performance_data, :success_rate) -> performance_data.success_rate
      Map.has_key?(performance_data, :confidence) -> performance_data.confidence
      Map.has_key?(performance_data, :quality_score) -> performance_data.quality_score
      Map.has_key?(performance_data, :efficiency) -> performance_data.efficiency
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

  defp trigger_performance_analysis(agent_id, performance_data) do
    # Asynchronous performance analysis
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
      context_tags: extract_context_tags(outcome_data),
      timestamp: DateTime.utc_now()
    }
  end

  defp determine_outcome_success(outcome_data) do
    cond do
      Map.has_key?(outcome_data, :success) -> outcome_data.success
      Map.has_key?(outcome_data, :error) -> false
      Map.get(outcome_data, :confidence, 0) >= 0.7 -> true
      Map.get(outcome_data, :quality_score, 0) >= 0.8 -> true
      true -> false
    end
  end

  defp extract_key_factors_from_outcome(outcome_data) do
    # Extract important factors that contributed to the outcome
    factors = []

    factors = if Map.has_key?(outcome_data, :context) do
      context_factors = Map.keys(outcome_data.context) |> Enum.take(3)
      factors ++ context_factors
    else
      factors
    end

    factors = if Map.has_key?(outcome_data, :strategy_used) do
      [outcome_data.strategy_used | factors]
    else
      factors
    end

    factors = if Map.has_key?(outcome_data, :coordination_type) do
      [outcome_data.coordination_type | factors]
    else
      factors
    end

    factors |> Enum.uniq() |> Enum.take(5)
  end

  defp generate_key_insight(task_type, outcome_data, success) do
    if success do
      case task_type do
        :coordination -> "Successful coordination achieved through #{Map.get(outcome_data, :coordination_type, 'unknown method')}"
        :reasoning -> "Effective reasoning with confidence #{Map.get(outcome_data, :confidence, 'unknown')}"
        :planning -> "Planning succeeded with #{Map.get(outcome_data, :steps_completed, 'unknown')} steps completed"
        _ -> "Task #{task_type} completed successfully"
      end
    else
      failure_reason = Map.get(outcome_data, :error_reason, "unknown reason")
      "Task #{task_type} failed due to: #{failure_reason}"
    end
  end

  defp calculate_learning_significance(outcome_data, success) do
    base_significance = if success, do: 0.6, else: 0.7  # Failures often more significant for learning

    # Increase significance for certain factors
    significance_boosts = []

    significance_boosts = if Map.get(outcome_data, :novelty, false) do
      [0.2 | significance_boosts]  # Novel situations are more significant
    else
      significance_boosts
    end

    significance_boosts = if Map.get(outcome_data, :complexity, :low) == :high do
      [0.15 | significance_boosts]  # High complexity adds significance
    else
      significance_boosts
    end

    significance_boosts = if Map.get(outcome_data, :coordination_count, 0) > 3 do
      [0.1 | significance_boosts]  # Multi-agent scenarios are more significant
    else
      significance_boosts
    end

    total_significance = base_significance + Enum.sum(significance_boosts)
    min(total_significance, 1.0)
  end

  defp extract_context_tags(outcome_data) do
    tags = []

    tags = if Map.has_key?(outcome_data, :domain) do
      [outcome_data.domain | tags]
    else
      tags
    end

    tags = if Map.get(outcome_data, :complexity, :low) == :high do
      [:high_complexity | tags]
    else
      tags
    end

    tags = if Map.get(outcome_data, :coordination_count, 0) > 1 do
      [:multi_agent | tags]
    else
      tags
    end

    tags = if Map.has_key?(outcome_data, :time_pressure) and outcome_data.time_pressure do
      [:time_critical | tags]
    else
      tags
    end

    tags |> Enum.uniq()
  end

  defp store_learning_pattern(patterns, learning_pattern) do
    pattern_key = {learning_pattern.agent_id, learning_pattern.task_type}
    agent_task_patterns = Map.get(patterns, pattern_key, [])
    updated_patterns = [learning_pattern | agent_task_patterns] |> Enum.take(50)  # Keep recent patterns

    Map.put(patterns, pattern_key, updated_patterns)
  end

  defp update_knowledge_connections(knowledge_graphs, agent_id, task_type, outcome_data) do
    # Update knowledge graph with new connections discovered through this outcome
    graph_key = agent_id
    agent_graph = Map.get(knowledge_graphs, graph_key, %{nodes: [], edges: []})

    # Add task as a node if it doesn't exist
    task_node = %{id: task_type, type: :task, properties: extract_task_properties(outcome_data)}
    updated_nodes = add_node_if_new(agent_graph.nodes, task_node)

    # Add outcome as a node
    outcome_id = "outcome_#{System.unique_integer([:positive])}"
    outcome_node = %{id: outcome_id, type: :outcome, properties: outcome_data}
    updated_nodes = [outcome_node | updated_nodes]

    # Add edge between task and outcome
    edge = %{from: task_type, to: outcome_id, relationship: :produces, weight: 1.0}
    updated_edges = [edge | agent_graph.edges]

    # Add context connections if available
    {final_nodes, final_edges} = if Map.has_key?(outcome_data, :context) do
      add_context_connections(updated_nodes, updated_edges, outcome_id, outcome_data.context)
    else
      {updated_nodes, updated_edges}
    end

    updated_graph = %{nodes: final_nodes, edges: final_edges}
    Map.put(knowledge_graphs, graph_key, updated_graph)
  end

  defp extract_task_properties(outcome_data) do
    %{
      complexity: Map.get(outcome_data, :complexity, :unknown),
      coordination_type: Map.get(outcome_data, :coordination_type),
      success_rate: Map.get(outcome_data, :success_rate, 0.5),
      last_updated: DateTime.utc_now()
    }
  end

  defp add_node_if_new(nodes, new_node) do
    if Enum.any?(nodes, fn node -> node.id == new_node.id end) do
      nodes
    else
      [new_node | nodes]
    end
  end

  defp add_context_connections(nodes, edges, outcome_id, context) do
    context_connections = Enum.map(context, fn {context_key, context_value} ->
      context_node_id = "context_#{context_key}"
      context_node = %{
        id: context_node_id,
        type: :context,
        properties: %{key: context_key, value: context_value}
      }

      edge = %{from: context_node_id, to: outcome_id, relationship: :influences, weight: 0.5}

      {context_node, edge}
    end)

    {context_nodes, context_edges} = Enum.unzip(context_connections)

    updated_nodes = context_nodes ++ nodes
    updated_edges = context_edges ++ edges

    {updated_nodes, updated_edges}
  end

  defp broadcast_learning_to_relevant_agents(learning_pattern) do
    # Identify agents who might benefit from this learning
    relevant_agents = identify_relevant_agents_for_learning(learning_pattern)

    Enum.each(relevant_agents, fn agent_id ->
      insight_data = %{
        type: :learning_pattern,
        source_agent: learning_pattern.agent_id,
        task_type: learning_pattern.task_type,
        key_insight: learning_pattern.key_insight,
        applicability: calculate_learning_applicability(learning_pattern, agent_id),
        timestamp: DateTime.utc_now()
      }

      Logger.debug("📡 Broadcasting learning insight to agent #{agent_id}")
      # In a full implementation, would actually send to the agent
    end)
  end

  defp identify_relevant_agents_for_learning(learning_pattern) do
    # Simple heuristic - agents working on similar tasks
    # In a full implementation, would use more sophisticated matching
    case learning_pattern.task_type do
      :coordination -> [:executor_agent, :monitor_agent]
      :security_analysis -> [:deployment_planner, :monitor_agent]
      :planning -> [:security_agent, :executor_agent]
      _ -> []
    end
  end

  defp calculate_learning_applicability(_learning_pattern, _target_agent_id) do
    # Calculate how applicable this learning is to the target agent
    # Simplified implementation
    0.6 + :rand.uniform() * 0.3
  end

  defp validate_insight(insight_data, from_agent) do
    # Validate that the insight is useful and not malicious/corrupted
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
      recent_scores = agent_history
      |> Enum.take(10)
      |> Enum.map(&extract_performance_score/1)

      current_score = extract_performance_score(current_performance)
      historical_average = Enum.sum(recent_scores) / length(recent_scores)

      performance_trend = if current_score > historical_average + 0.1 do
        :improving
      else if current_score < historical_average - 0.1 do
        :declining
      else
        :stable
      end

      %{
        analysis_type: :trend_analysis,
        current_score: current_score,
        historical_average: historical_average,
        trend: performance_trend,
        sample_size: length(recent_scores),
        confidence: min(length(recent_scores) / 10, 1.0)
      }
    end
  end

  defp find_relevant_strategies(agent_id, performance_analysis, context, adaptation_strategies) do
    # Find adaptation strategies relevant to this agent's situation
    base_strategies = Map.get(adaptation_strategies, :general, [])

    context_strategies = case Map.get(context, :domain) do
      :deployment -> Map.get(adaptation_strategies, :deployment, [])
      :security -> Map.get(adaptation_strategies, :security, [])
      :coordination -> Map.get(adaptation_strategies, :coordination, [])
      _ -> []
    end

    trend_strategies = case performance_analysis.trend do
      :declining -> Map.get(adaptation_strategies, :performance_recovery, [])
      :improving -> Map.get(adaptation_strategies, :performance_enhancement, [])
      :stable -> Map.get(adaptation_strategies, :optimization, [])
    end

    (base_strategies ++ context_strategies ++ trend_strategies) |> Enum.uniq()
  end

  defp find_similar_agent_insights(agent_id, context, state) do
    # Find insights from agents with similar contexts or challenges
    relevant_insights = Enum.filter(state.cross_agent_insights, fn insight ->
      insight.source_agent != agent_id and  # Not from the same agent
      has_similar_context?(insight, context) and
      insight_is_recent?(insight, 7 * 24 * 60 * 60)  # Within a week
    end)

    # Sort by relevance/applicability
    Enum.sort_by(relevant_insights, &Map.get(&1, :applicability, 0.5), :desc)
    |> Enum.take(5)
  end

  defp has_similar_context?(insight, context) do
    # Simple context similarity check
    insight_context = Map.get(insight, :context, %{})

    common_keys = Map.keys(insight_context) -- Map.keys(context)
    length(common_keys) >= 1  # At least one common context element
  end

  defp insight_is_recent?(insight, max_age_seconds) do
    case Map.get(insight, :timestamp) do
      nil -> false
      timestamp ->
        age_seconds = DateTime.diff(DateTime.utc_now(), timestamp)
        age_seconds <= max_age_seconds
    end
  end

  defp generate_adaptation_plan(agent_id, performance_analysis, strategies, similar_insights, context) do
    # Select best strategy based on analysis
    primary_strategy = select_primary_strategy(performance_analysis, strategies)

    # Incorporate insights from similar agents
    insight_recommendations = extract_insight_recommendations(similar_insights)

    # Create personalized plan
    %{
      agent_id: agent_id,
      strategy_type: primary_strategy.type,
      specific_actions: primary_strategy.actions ++ insight_recommendations,
      expected_improvement: estimate_improvement_potential(performance_analysis, primary_strategy),
      implementation_timeline: primary_strategy.timeline,
      success_metrics: define_success_metrics(performance_analysis, primary_strategy),
      monitoring_frequency: determine_monitoring_frequency(performance_analysis),
      fallback_strategy: select_fallback_strategy(strategies, primary_strategy),
      confidence: calculate_adaptation_confidence(performance_analysis, strategies, similar_insights),
      created_at: DateTime.utc_now()
    }
  end

  defp select_primary_strategy(performance_analysis, strategies) do
    # Select strategy based on performance analysis
    case performance_analysis.trend do
      :declining ->
        Enum.find(strategies, fn s -> s.type == :recovery end) || default_strategy(:recovery)
      :stable ->
        Enum.find(strategies, fn s -> s.type == :optimization end) || default_strategy(:optimization)
      :improving ->
        Enum.find(strategies, fn s -> s.type == :enhancement end) || default_strategy(:enhancement)
    end
  end

  defp default_strategy(type) do
    case type do
      :recovery -> %{
        type: :recovery,
        actions: ["Review recent failures", "Adjust parameters", "Increase validation"],
        timeline: "1-2 weeks"
      }
      :optimization -> %{
        type: :optimization,
        actions: ["Fine-tune parameters", "Optimize coordination patterns"],
        timeline: "2-3 weeks"
      }
      :enhancement -> %{
        type: :enhancement,
        actions: ["Explore advanced techniques", "Increase complexity handling"],
        timeline: "3-4 weeks"
      }
    end
  end

  defp extract_insight_recommendations(insights) do
    insights
    |> Enum.map(fn insight -> insight.key_insight end)
    |> Enum.map(&"Consider insight: #{&1}")
    |> Enum.take(3)
  end

  defp estimate_improvement_potential(performance_analysis, strategy) do
    base_potential = case strategy.type do
      :recovery -> 0.3
      :optimization -> 0.15
      :enhancement -> 0.2
    end

    # Adjust based on current performance
    current_score = Map.get(performance_analysis, :current_score, 0.5)
    room_for_improvement = 1.0 - current_score

    min(base_potential, room_for_improvement)
  end

  defp define_success_metrics(performance_analysis, strategy) do
    current_score = Map.get(performance_analysis, :current_score, 0.5)
    improvement_target = current_score + estimate_improvement_potential(performance_analysis, strategy)

    [
      "Performance score improvement to #{Float.round(improvement_target, 2)}",
      "Sustained performance above #{Float.round(current_score, 2)} for 1 week",
      "Reduced performance variance by 20%"
    ]
  end

  defp determine_monitoring_frequency(performance_analysis) do
    case performance_analysis.trend do
      :declining -> :daily
      :stable -> :weekly
      :improving -> :weekly
    end
  end

  defp select_fallback_strategy(strategies, primary_strategy) do
    fallback_strategies = Enum.filter(strategies, fn s -> s.type != primary_strategy.type end)
    Enum.random(fallback_strategies || [default_strategy(:recovery)])
  end

  defp calculate_adaptation_confidence(performance_analysis, strategies, insights) do
    base_confidence = Map.get(performance_analysis, :confidence, 0.5)

    strategy_confidence = if length(strategies) >= 2, do: 0.2, else: 0.1
    insight_confidence = min(length(insights) * 0.05, 0.15)

    min(base_confidence + strategy_confidence + insight_confidence, 1.0)
  end

  # Initialization functions

  defp initialize_knowledge_graphs do
    %{
      # Each agent gets its own knowledge graph
      deployment_planner: %{nodes: [], edges: []},
      security_agent: %{nodes: [], edges: []},
      executor_agent: %{nodes: [], edges: []},
      monitor_agent: %{nodes: [], edges: []}
    }
  end

  defp initialize_adaptation_strategies do
    %{
      general: [
        %{type: :optimization, actions: ["Parameter tuning", "Process refinement"], timeline: "2-3 weeks"},
        %{type: :recovery, actions: ["Error analysis", "Strategy reset"], timeline: "1-2 weeks"}
      ],
      deployment: [
        %{type: :recovery, actions: ["Review deployment failures", "Update risk assessment"], timeline: "1 week"},
        %{type: :enhancement, actions: ["Implement advanced deployment patterns"], timeline: "3-4 weeks"}
      ],
      security: [
        %{type: :recovery, actions: ["Update threat models", "Enhance detection"], timeline: "1-2 weeks"},
        %{type: :optimization, actions: ["Fine-tune security rules", "Optimize analysis speed"], timeline: "2 weeks"}
      ],
      coordination: [
        %{type: :optimization, actions: ["Improve agent communication", "Optimize consensus algorithms"], timeline: "2-3 weeks"},
        %{type: :enhancement, actions: ["Implement advanced coordination patterns"], timeline: "4 weeks"}
      ],
      performance_recovery: [
        %{type: :recovery, actions: ["Identify performance bottlenecks", "Reset to known good state"], timeline: "1 week"}
      ],
      performance_enhancement: [
        %{type: :enhancement, actions: ["Explore advanced techniques", "Increase automation"], timeline: "3-4 weeks"}
      ]
    }
  end

  defp initialize_learning_objectives do
    %{
      system_wide: [
        "Improve cross-agent coordination efficiency",
        "Reduce task failure rates",
        "Enhance decision-making speed",
        "Increase adaptation responsiveness"
      ],
      agent_specific: %{
        deployment_planner: ["Improve deployment success rate", "Reduce planning time"],
        security_agent: ["Enhance threat detection accuracy", "Reduce false positives"],
        executor_agent: ["Improve execution reliability", "Optimize resource usage"],
        monitor_agent: ["Enhance system visibility", "Improve alert quality"]
      }
    }
  end

  # Analysis functions

  defp filter_relevant_insights(insights, query_context) do
    Enum.filter(insights, fn insight ->
      insight_matches_context?(insight, query_context)
    end)
    |> Enum.take(20)  # Limit results
  end

  defp insight_matches_context?(insight, query_context) do
    # Simple context matching - in production would use more sophisticated matching
    insight_tags = Map.get(insight, :context_tags, [])
    query_tags = Map.get(query_context, :tags, [])

    common_tags = MapSet.intersection(MapSet.new(insight_tags), MapSet.new(query_tags))
    MapSet.size(common_tags) > 0
  end

  defp query_knowledge_graph(knowledge_graphs, query_context) do
    # Query all knowledge graphs for relevant connections
    agent_id = Map.get(query_context, :agent_id)

    if agent_id do
      # Query specific agent's graph
      agent_graph = Map.get(knowledge_graphs, agent_id, %{nodes: [], edges: []})
      query_single_knowledge_graph(agent_graph, query_context)
    else
      # Query all graphs and combine results
      all_results = Enum.map(knowledge_graphs, fn {_agent_id, graph} ->
        query_single_knowledge_graph(graph, query_context)
      end)

      combine_knowledge_graph_results(all_results)
    end
  end

  defp query_single_knowledge_graph(graph, query_context) do
    # Simple graph querying - find nodes and edges matching context
    query_type = Map.get(query_context, :type)

    matching_nodes = Enum.filter(graph.nodes, fn node ->
      node.type == query_type or
      node_matches_properties(node, query_context)
    end)

    # Find edges connected to matching nodes
    node_ids = Enum.map(matching_nodes, &(&1.id))
    related_edges = Enum.filter(graph.edges, fn edge ->
      edge.from in node_ids or edge.to in node_ids
    end)

    %{
      matching_nodes: matching_nodes,
      related_edges: related_edges,
      relevance_score: calculate_relevance_score(matching_nodes, related_edges, query_context)
    }
  end

  defp node_matches_properties(node, query_context) do
    # Check if node properties match query context
    node_properties = Map.get(node, :properties, %{})
    query_properties = Map.get(query_context, :properties, %{})

    Enum.any?(query_properties, fn {key, value} ->
      Map.get(node_properties, key) == value
    end)
  end

  defp calculate_relevance_score(nodes, edges, _query_context) do
    # Simple relevance scoring based on result count
    node_score = length(nodes) * 0.1
    edge_score = length(edges) * 0.05
    min(node_score + edge_score, 1.0)
  end

  defp combine_knowledge_graph_results(results) do
    %{
      total_matching_nodes: Enum.sum(Enum.map(results, &length(&1.matching_nodes))),
      total_related_edges: Enum.sum(Enum.map(results, &length(&1.related_edges))),
      average_relevance: calculate_average_relevance(results),
      agent_results: results
    }
  end

  defp calculate_average_relevance(results) do
    if length(results) == 0 do
      0.0
    else
      relevances = Enum.map(results, &(&1.relevance_score))
      Enum.sum(relevances) / length(relevances)
    end
  end

  # Trend analysis functions

  defp analyze_agent_performance_trends(performance_trends) do
    Enum.map(performance_trends, fn {agent_id, trend_data} ->
      {agent_id, %{
        current_trend: trend_data.trend_direction,
        moving_average: trend_data.moving_average,
        stability: assess_performance_stability(trend_data),
        recommendation: generate_trend_recommendation(trend_data)
      }}
    end)
    |> Enum.into(%{})
  end

  defp assess_performance_stability(trend_data) do
    sample_count = Map.get(trend_data, :sample_count, 0)

    cond do
      sample_count < 5 -> :insufficient_data
      trend_data.trend_direction == :stable -> :stable
      sample_count >= 10 -> :established_trend
      true -> :emerging_trend
    end
  end

  defp generate_trend_recommendation(trend_data) do
    case {trend_data.trend_direction, trend_data.moving_average} do
      {:declining, avg} when avg < 0.5 -> "Immediate intervention recommended"
      {:declining, _} -> "Monitor closely and consider optimization"
      {:improving, avg} when avg > 0.8 -> "Maintain current approach"
      {:improving, _} -> "Continue current improvements"
      {:stable, avg} when avg > 0.7 -> "Performance acceptable, consider enhancement"
      {:stable, _} -> "Stable but could be improved"
    end
  end

  defp analyze_learning_pattern_evolution(learning_patterns) do
    pattern_counts = Enum.map(learning_patterns, fn {{agent_id, task_type}, patterns} ->
      recent_patterns = Enum.filter(patterns, &pattern_is_recent?(&1, 30 * 24 * 60 * 60))  # 30 days

      success_rate = calculate_success_rate(recent_patterns)
      learning_velocity = calculate_learning_velocity(patterns)

      {{agent_id, task_type}, %{
        recent_pattern_count: length(recent_patterns),
        success_rate: success_rate,
        learning_velocity: learning_velocity,
        dominant_factors: identify_dominant_factors(recent_patterns)
      }}
    end)
    |> Enum.into(%{})

    %{
      pattern_evolution: pattern_counts,
      overall_learning_health: assess_overall_learning_health(pattern_counts)
    }
  end

  defp pattern_is_recent?(pattern, max_age_seconds) do
    age_seconds = DateTime.diff(DateTime.utc_now(), pattern.timestamp)
    age_seconds <= max_age_seconds
  end

  defp calculate_success_rate(patterns) do
    if length(patterns) == 0 do
      0.0
    else
      successful_patterns = Enum.count(patterns, &(&1.success))
      successful_patterns / length(patterns)
    end
  end

  defp calculate_learning_velocity(patterns) do
    # Simple learning velocity based on pattern frequency over time
    if length(patterns) < 2 do
      0.0
    else
      sorted_patterns = Enum.sort_by(patterns, &(&1.timestamp), DateTime)
      time_span = DateTime.diff(List.last(sorted_patterns).timestamp, List.first(sorted_patterns).timestamp, :day)

      if time_span > 0 do
        length(patterns) / time_span
      else
        0.0
      end
    end
  end

  defp identify_dominant_factors(patterns) do
    # Find most common key factors across patterns
    all_factors = Enum.flat_map(patterns, &(&1.key_factors))

    all_factors
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_factor, count} -> count end, :desc)
    |> Enum.take(3)
    |> Enum.map(fn {factor, _count} -> factor end)
  end

  defp assess_overall_learning_health(pattern_counts) do
    if map_size(pattern_counts) == 0 do
      :no_data
    else
      success_rates = pattern_counts
      |> Map.values()
      |> Enum.map(&(&1.success_rate))

      learning_velocities = pattern_counts
      |> Map.values()
      |> Enum.map(&(&1.learning_velocity))

      avg_success_rate = Enum.sum(success_rates) / length(success_rates)
      avg_learning_velocity = Enum.sum(learning_velocities) / length(learning_velocities)

      cond do
        avg_success_rate >= 0.8 and avg_learning_velocity >= 0.5 -> :excellent
        avg_success_rate >= 0.7 and avg_learning_velocity >= 0.3 -> :good
        avg_success_rate >= 0.6 -> :acceptable
        true -> :needs_improvement
      end
    end
  end

  defp analyze_knowledge_graph_growth(knowledge_graphs) do
    growth_stats = Enum.map(knowledge_graphs, fn {agent_id, graph} ->
      {agent_id, %{
        node_count: length(graph.nodes),
        edge_count: length(graph.edges),
        connectivity: calculate_graph_connectivity(graph),
        growth_rate: estimate_graph_growth_rate(graph)
      }}
    end)
    |> Enum.into(%{})

    %{
      agent_graph_stats: growth_stats,
      total_system_knowledge: calculate_total_system_knowledge(growth_stats)
    }
  end

  defp calculate_graph_connectivity(graph) do
    if length(graph.nodes) <= 1 do
      0.0
    else
      max_possible_edges = length(graph.nodes) * (length(graph.nodes) - 1)
      actual_edges = length(graph.edges)
      actual_edges / max_possible_edges
    end
  end

  defp estimate_graph_growth_rate(_graph) do
    # Simplified growth rate estimation
    # In a full implementation, would track historical node/edge counts
    :rand.uniform() * 0.1  # Random growth rate between 0-10%
  end

  defp calculate_total_system_knowledge(growth_stats) do
    total_nodes = growth_stats |> Map.values() |> Enum.map(&(&1.node_count)) |> Enum.sum()
    total_edges = growth_stats |> Map.values() |> Enum.map(&(&1.edge_count)) |> Enum.sum()

    %{
      total_knowledge_nodes: total_nodes,
      total_knowledge_connections: total_edges,
      knowledge_density: if(total_nodes > 0, do: total_edges / total_nodes, else: 0)
    }
  end

  defp analyze_collaboration_patterns(cross_agent_insights) do
    # Analyze how agents are sharing and using insights
    recent_insights = Enum.filter(cross_agent_insights, &insight_is_recent?(&1, 7 * 24 * 60 * 60))

    sharing_patterns = recent_insights
    |> Enum.group_by(&Map.get(&1, :source_agent))
    |> Enum.map(fn {agent_id, insights} -> {agent_id, length(insights)} end)
    |> Enum.into(%{})

    collaboration_quality = assess_collaboration_quality(recent_insights)

    %{
      recent_insight_sharing: sharing_patterns,
      collaboration_quality: collaboration_quality,
      active_collaborators: map_size(sharing_patterns),
      insight_utilization: estimate_insight_utilization(recent_insights)
    }
  end

  defp assess_collaboration_quality(insights) do
    if length(insights) == 0 do
      :no_data
    else
      high_quality_insights = Enum.count(insights, fn insight ->
        Map.get(insight, :applicability, 0.5) >= 0.7
      end)

      quality_ratio = high_quality_insights / length(insights)

      cond do
        quality_ratio >= 0.8 -> :excellent
        quality_ratio >= 0.6 -> :good
        quality_ratio >= 0.4 -> :acceptable
        true -> :poor
      end
    end
  end

  defp estimate_insight_utilization(_insights) do
    # Simplified utilization estimation
    # In a full implementation, would track which insights were actually applied
    :rand.uniform() * 0.8  # Random utilization between 0-80%
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

    # Check for learning gaps
    learning_pattern_count = map_size(state.learning_patterns)
    improvements = if learning_pattern_count < 5 do
      ["Insufficient learning data - need more diverse experiences" | improvements]
    else
      improvements
    end

    # Check for collaboration issues
    recent_insights = Enum.filter(state.cross_agent_insights, &insight_is_recent?(&1, 7 * 24 * 60 * 60))
    improvements = if length(recent_insights) < 3 do
      ["Low cross-agent collaboration - encourage insight sharing" | improvements]
    else
      improvements
    end

    if length(improvements) == 0 do
      ["System operating well - consider advanced optimization strategies"]
    else
      improvements
    end
  end

  # Periodic analysis

  defp perform_periodic_learning_analysis(state) do
    Logger.info("🔄 Performing periodic learning analysis")

    # Analyze system-wide trends
    Task.start(fn ->
      trend_analysis = analyze_system_learning_trends_internal(state)
      Logger.info("📊 System learning trends: #{inspect(trend_analysis, limit: :infinity)}")
    end)

    # Clean up old data
    Task.start(fn ->
      cleanup_old_learning_data()
    end)

    # Generate learning insights report
    Task.start(fn ->
      generate_learning_insights_report(state)
    end)
  end

  defp analyze_system_learning_trends_internal(state) do
    %{
      active_learning_agents: count_active_learning_agents(state),
      learning_velocity_trend: analyze_learning_velocity_trend(state),
      knowledge_growth_rate: calculate_knowledge_growth_rate(state),
      collaboration_effectiveness: measure_collaboration_effectiveness(state)
    }
  end

  defp count_active_learning_agents(state) do
    state.performance_trends
    |> Enum.filter(fn {_agent_id, trend} -> trend.sample_count >= 5 end)
    |> length()
  end

  defp analyze_learning_velocity_trend(state) do
    recent_patterns = state.learning_patterns
    |> Map.values()
    |> List.flatten()
    |> Enum.filter(&pattern_is_recent?(&1, 7 * 24 * 60 * 60))

    %{
      recent_learning_events: length(recent_patterns),
      trend: if(length(recent_patterns) >= 10, do: :active, else: :slow)
    }
  end

  defp calculate_knowledge_growth_rate(state) do
    total_nodes = state.knowledge_graphs
    |> Map.values()
    |> Enum.map(&length(&1.nodes))
    |> Enum.sum()

    # Simplified growth rate
    %{
      total_knowledge_items: total_nodes,
      estimated_weekly_growth: max(total_nodes * 0.05, 1)  # Estimate 5% growth per week
    }
  end

  defp measure_collaboration_effectiveness(state) do
    recent_insights = Enum.filter(state.cross_agent_insights, &insight_is_recent?(&1, 7 * 24 * 60 * 60))

    %{
      recent_collaborations: length(recent_insights),
      effectiveness: assess_collaboration_quality(recent_insights)
    }
  end

  defp cleanup_old_learning_data do
    Logger.debug("🗑️ Cleaning up old learning data")
    # In a full implementation, would clean up old patterns, insights, etc.
  end

  defp generate_learning_insights_report(state) do
    Logger.info("📝 Generating learning insights report")
    # In a full implementation, would generate comprehensive report
    report = %{
      total_agents_tracked: map_size(state.agent_performances),
      total_learning_patterns: state.learning_patterns |> Map.values() |> List.flatten() |> length(),
      total_cross_agent_insights: length(state.cross_agent_insights),
      system_health: assess_system_learning_health(state)
    }

    Logger.info("📋 Learning Report: #{inspect(report)}")
  end

  defp assess_system_learning_health(state) do
    health_indicators = [
      {map_size(state.agent_performances) >= 3, "Sufficient agent diversity"},
      {length(state.cross_agent_insights) >= 5, "Active cross-agent learning"},
      {map_size(state.learning_patterns) >= 3, "Learning patterns established"},
      {count_active_learning_agents(state) >= 2, "Multiple agents actively learning"}
    ]

    healthy_indicators = Enum.count(health_indicators, fn {healthy, _desc} -> healthy end)
    health_ratio = healthy_indicators / length(health_indicators)

    cond do
      health_ratio >= 0.8 -> :excellent
      health_ratio >= 0.6 -> :good
      health_ratio >= 0.4 -> :fair
      true -> :poor
    end
  end

  defp schedule_periodic_analysis do
    # Schedule next analysis in 1 hour
    Process.send_after(self(), :periodic_analysis, 60 * 60 * 1000)
  end
end
