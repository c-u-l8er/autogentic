#!/usr/bin/env elixir

# Learning Agent - Adaptive Behavior Example
# This example demonstrates how agents can learn and adapt their behavior over time

defmodule AdaptiveLearningAgent do
  use Autogentic.Agent, name: :learning_agent
  require Logger

  agent :learning_agent do
    capability [:learning, :adaptation, :pattern_recognition]
    reasoning_style :adaptive
    initial_state :observing
  end

  state :observing do
    # Observing patterns and collecting data
  end

  state :learning do
    # Actively learning from experiences
  end

  state :adapting do
    # Adapting behavior based on learned patterns
  end

  transition from: :observing, to: :learning, when_receives: :start_learning do
    sequence do
      log(:info, "🧠 Starting learning process")
      put_data(:learning_started, DateTime.utc_now())
      put_data(:observations_collected, get_observation_count())
    end
  end

  transition from: :learning, to: :adapting, when_receives: :learning_complete do
    sequence do
      log(:info, "📚 Learning complete, adapting behavior")
      put_data(:adaptation_started, DateTime.utc_now())
      put_data(:patterns_learned, get_learned_patterns())
      learn_from_outcome("behavior_adaptation", "successful_learning_cycle")
    end
  end

  transition from: :adapting, to: :observing, when_receives: :adaptation_complete do
    sequence do
      log(:info, "🔄 Adaptation complete, returning to observation")
      put_data(:learning_cycle_completed, DateTime.utc_now())
      put_data(:behavior_updated, true)
      emit_event(:learning_cycle_finished, %{agent: :learning_agent})
    end
  end

  # Behavior that adapts based on experience
  behavior :adaptive_response, triggers_on: [:experience_event] do
    sequence do
      log(:debug, "⚡ Processing experience event")
      increment_data(:experiences_processed)
      store_reasoning_pattern("experience_pattern", get_current_pattern())
    end
  end

  # Learn from successful outcomes
  behavior :success_learning, triggers_on: [:success_outcome] do
    sequence do
      log(:info, "✅ Learning from successful outcome")
      increment_data(:successful_outcomes)
      learn_from_outcome("success_pattern", get_success_details())
      update_behavior_model("success_model", get_model_updates())
    end
  end

  # Learn from failures
  behavior :failure_learning, triggers_on: [:failure_outcome] do
    sequence do
      log(:warning, "❌ Learning from failure outcome")
      increment_data(:failure_outcomes)
      learn_from_outcome("failure_pattern", get_failure_details())
      {:adapt_coordination_strategy, get_new_strategy()}
    end
  end

  # Helper functions (simplified for example)
  defp get_observation_count, do: :rand.uniform(100) + 50
  defp get_learned_patterns, do: ["pattern_a", "pattern_b", "pattern_c"]

  defp get_current_pattern, do: %{type: :adaptive, confidence: 0.8}
  defp get_success_details, do: %{strategy: :collaborative, outcome: :positive}
  defp get_failure_details, do: %{strategy: :isolated, outcome: :negative}
  defp get_model_updates, do: %{weight_adjustment: 0.1, bias_correction: 0.05}
  defp get_new_strategy, do: %{approach: :cautious, coordination_level: :high}

  # Handle get_state calls from Autogentic.get_agent_state/1
  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state_and_data, {:reply, from, {:ok, {state, data}}}}
  end

  # Handle internal context merging from behaviors and transitions
  def handle_event(:info, {:internal_merge_context, new_context}, state, data) do
    Logger.debug("🔄 [AdaptiveLearningAgent] Internal merging context: #{inspect(new_context)} into existing: #{inspect(data.context)}")
    updated_context = Map.merge(data.context, new_context)
    updated_data = %{data | context: updated_context}
    Logger.debug("🎯 [AdaptiveLearningAgent] Final internally merged context: #{inspect(updated_context)}")
    {:keep_state, updated_data}
  end
end

# Example demonstrating continuous learning
defmodule ContinuousLearningDemo do
  def run do
    IO.puts("🧠 Continuous Learning Demo")
    IO.puts(String.duplicate("=", 40))

    # Start learning agent
    {:ok, agent_pid} = AdaptiveLearningAgent.start_link()
    IO.puts("🤖 Adaptive learning agent started")

    # Simulate learning cycles
    simulate_learning_cycles(agent_pid)

    # Wait a bit more before showing final progress to ensure all async effects completed
    Process.sleep(500)

    # Show learning progress
    show_learning_progress(agent_pid)

    # Cleanup
    GenStateMachine.stop(agent_pid)

    IO.puts("\n✨ Continuous learning demo completed!")
  end

  defp simulate_learning_cycles(agent_pid) do
    IO.puts("\n🔄 Simulating learning cycles...")

    # Cycle 1: Initial learning
    IO.puts("\n📚 Learning Cycle 1:")
    run_learning_cycle(agent_pid, "Initial pattern recognition")

    # Simulate some successful experiences
    IO.puts("\n✅ Processing successful experiences...")
    GenStateMachine.cast(agent_pid, :success_outcome)
    GenStateMachine.cast(agent_pid, :experience_event)
    Process.sleep(500)  # Wait longer for async effects to complete

    # Cycle 2: Adaptive learning
    IO.puts("\n📚 Learning Cycle 2:")
    run_learning_cycle(agent_pid, "Adaptive behavior refinement")

    # Simulate some failures to learn from
    IO.puts("\n❌ Processing failure experiences...")
    GenStateMachine.cast(agent_pid, :failure_outcome)
    GenStateMachine.cast(agent_pid, :experience_event)
    Process.sleep(500)  # Wait longer for async effects to complete

    # Cycle 3: Advanced adaptation
    IO.puts("\n📚 Learning Cycle 3:")
    run_learning_cycle(agent_pid, "Advanced pattern adaptation")
  end

  defp run_learning_cycle(agent_pid, description) do
    IO.puts("  #{description}")

    # Start learning
    GenStateMachine.cast(agent_pid, :start_learning)
    Process.sleep(150)

    # Complete learning
    GenStateMachine.cast(agent_pid, :learning_complete)
    Process.sleep(100)

    # Complete adaptation
    GenStateMachine.cast(agent_pid, :adaptation_complete)
    Process.sleep(100)

    # Show current state
    {state, data} = Autogentic.get_agent_state(agent_pid)
    IO.puts("  State: #{state}")

    if data.context[:patterns_learned] do
      patterns = data.context[:patterns_learned]
      IO.puts("  Learned patterns: #{inspect(patterns)}")
    end
  end

  defp show_learning_progress(agent_pid) do
    IO.puts("\n📊 Learning Progress Summary:")
    IO.puts(String.duplicate("-", 30))

    {_state, data} = Autogentic.get_agent_state(agent_pid)
    context = data.context

    IO.puts("🔍 DEBUG: Full agent context: #{inspect(context, pretty: true)}")

    IO.puts("Observations collected: #{context[:observations_collected] || 0}")
    IO.puts("Experiences processed: #{context[:experiences_processed] || 0}")
    IO.puts("Successful outcomes: #{context[:successful_outcomes] || 0}")
    IO.puts("Failure outcomes: #{context[:failure_outcomes] || 0}")
    IO.puts("Behavior updated: #{context[:behavior_updated] || false}")

    if context[:learning_cycle_completed] do
      IO.puts("Last learning cycle: #{context[:learning_cycle_completed]}")
    end
  end
end

# Example using reasoning for learning optimization
defmodule LearningOptimizationDemo do
  def run do
    IO.puts("\n🎯 Learning Optimization with Reasoning")
    IO.puts(String.duplicate("=", 45))

    # Use reasoning to optimize learning strategy
    context = %{
      learning_rate: 0.01,
      experience_count: 150,
      success_rate: 0.75,
      adaptation_speed: :moderate,
      domain_complexity: :high
    }

    IO.puts("🤔 Reasoning about learning optimization...")
    {:ok, session_id} = Autogentic.start_reasoning("learning_optimization", context)

    # Step 1: Assess current learning performance
    step1 = %{
      id: :learning_assessment,
      question: "How effective is the current learning approach?",
      analysis_type: :assessment,
      context_required: [:learning_rate, :success_rate, :experience_count]
    }

    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step1)

    # Step 2: Evaluate adaptation needs
    step2 = %{
      id: :adaptation_evaluation,
      question: "What adaptations would improve learning?",
      analysis_type: :evaluation,
      context_required: [:adaptation_speed, :domain_complexity]
    }

    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step2)

    # Step 3: Synthesize optimization strategy
    step3 = %{
      id: :optimization_synthesis,
      question: "What's the optimal learning strategy?",
      analysis_type: :synthesis,
      context_required: [:learning_rate, :success_rate, :adaptation_speed, :domain_complexity]
    }

    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step3)

    # Get conclusion
    {:ok, conclusion} = Autogentic.Reasoning.Engine.conclude_reasoning_session(session_id)

    IO.puts("\n📋 Learning Optimization Results:")
    IO.puts("Confidence: #{conclusion.confidence}")
    IO.puts("Recommendation: #{conclusion.recommendation}")
    IO.puts("Key insights: #{inspect(conclusion.key_insights, pretty: true)}")
    IO.puts("Reasoning quality: #{conclusion.reasoning_quality}")
  end
end

# Cross-agent learning demonstration
defmodule CollaborativeLearningDemo do
  def run do
    IO.puts("\n🤝 Collaborative Learning Demo")
    IO.puts(String.duplicate("=", 40))

    # Show how agents can share learned knowledge
    IO.puts("🔄 Demonstrating knowledge sharing between agents...")

    # This would involve multiple agents sharing reasoning patterns
    # and learned behaviors through the effects system

    # Simulate knowledge sharing effect
    IO.puts("📤 Agent A sharing learned pattern...")
    sharing_effect = {:sequence, [
      {:log, :info, "Sharing learned pattern with peer agents"},
      {:store_reasoning_pattern, "collaborative_pattern", %{
        shared_by: :agent_a,
        pattern_type: :optimization,
        confidence: 0.9,
        usage_count: 15
      }},
      {:broadcast_reasoning, "New optimization pattern available", [:agent_b, :agent_c]},
      {:emit_event, :knowledge_shared, %{pattern: "collaborative_pattern"}}
    ]}

    {:ok, result} = Autogentic.execute_effect(sharing_effect)
    IO.puts("✅ Knowledge sharing completed: #{inspect(result)}")

    IO.puts("\n📚 Benefits of collaborative learning:")
    IO.puts("• Faster convergence to optimal strategies")
    IO.puts("• Reduced redundant learning across agents")
    IO.puts("• Improved overall system performance")
    IO.puts("• Enhanced fault tolerance through shared knowledge")
  end
end

# Main example runner
defmodule LearningAgentExample do
  def run do
    ContinuousLearningDemo.run()
    LearningOptimizationDemo.run()
    CollaborativeLearningDemo.run()
  end
end

# Auto-run the example
LearningAgentExample.run()
