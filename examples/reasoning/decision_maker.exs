#!/usr/bin/env elixir

# Decision Maker - Advanced Reasoning Example
# This example demonstrates Autogentic's sophisticated reasoning capabilities

defmodule DecisionMakerAgent do
  use Autogentic.Agent, name: :decision_maker
  require Logger

  agent :decision_maker do
    capability [:analysis, :decision_making, :risk_assessment]
    reasoning_style :analytical
    initial_state :ready
  end

  state :ready do
    # Ready to receive decision requests
  end

  state :analyzing do
    # Performing deep analysis
  end

  state :deciding do
    # Making final decision
  end

  transition from: :ready, to: :analyzing, when_receives: :analyze_request do
    sequence do
      log(:info, "🧠 Starting analysis phase")
      put_data(:analysis_started, DateTime.utc_now())
      put_data(:current_phase, :analysis)
    end
  end

  transition from: :analyzing, to: :deciding, when_receives: :analysis_complete do
    sequence do
      log(:info, "📊 Analysis complete, moving to decision phase")
      put_data(:decision_phase_started, DateTime.utc_now())
      put_data(:current_phase, :decision)
    end
  end

  transition from: :deciding, to: :ready, when_receives: :decision_made do
    sequence do
      log(:info, "✅ Decision made, ready for next request")
      put_data(:last_decision_at, DateTime.utc_now())
      put_data(:current_phase, :ready)
      emit_event(:decision_completed, %{agent: :decision_maker})
    end
  end

  # Handle get_state calls from Autogentic.get_agent_state/1
  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state_and_data, {:reply, from, {:ok, {state, data}}}}
  end
end

defmodule ReasoningShowcase do
  def run do
    IO.puts("🧠 Advanced Reasoning Showcase")
    IO.puts(String.duplicate("=", 50))

    # Demonstrate different types of reasoning
    basic_reasoning_demo()
    multi_step_reasoning_demo()
    decision_analysis_demo()

    IO.puts("\n✨ Reasoning showcase completed!")
  end

  defp basic_reasoning_demo do
    IO.puts("\n1. 🔍 Basic Reasoning Demo")
    IO.puts(String.duplicate("-", 30))

    # Start a simple reasoning session
    context = %{
      task: "evaluate_deployment_readiness",
      environment: :production,
      urgency: :normal
    }

    IO.puts("🎯 Starting reasoning session...")
    {:ok, session_id} = Autogentic.start_reasoning("basic_analysis", context)
    IO.puts("Session ID: #{session_id}")

    # Add a reasoning step
    step = %{
      id: :assess_readiness,
      question: "Is the system ready for deployment?",
      analysis_type: :assessment,
      context_required: [:environment, :urgency],
      output_format: :analysis
    }

    IO.puts("\n🤔 Adding reasoning step...")
    {:ok, processed_step} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step)
    IO.puts("Step processed with confidence: #{processed_step.confidence}")
    IO.puts("Analysis result: #{inspect(processed_step.analysis_result, pretty: true)}")

    # Conclude the session
    IO.puts("\n🎯 Concluding reasoning session...")
    {:ok, conclusion} = Autogentic.Reasoning.Engine.conclude_reasoning_session(session_id)
    IO.puts("Session concluded with overall confidence: #{conclusion.confidence}")
    IO.puts("Recommendation: #{conclusion.recommendation}")
  end

  defp multi_step_reasoning_demo do
    IO.puts("\n2. 🔗 Multi-Step Reasoning Demo")
    IO.puts(String.duplicate("-", 30))

    context = %{
      project: "autogentic_v2",
      complexity: :high,
      timeline: :tight,
      resources: :adequate,
      stakeholders: [:engineering, :product, :qa]
    }

    {:ok, session_id} = Autogentic.start_reasoning("complex_analysis", context)
    IO.puts("🎯 Started complex analysis session: #{session_id}")

    # Step 1: Assess complexity
    step1 = %{
      id: :complexity_assessment,
      question: "How complex is this project?",
      analysis_type: :assessment,
      context_required: [:project, :complexity],
      output_format: :analysis
    }

    IO.puts("\n1️⃣ Assessing project complexity...")
    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step1)

    # Step 2: Evaluate timeline
    step2 = %{
      id: :timeline_evaluation,
      question: "Is the timeline realistic given the complexity?",
      analysis_type: :evaluation,
      context_required: [:complexity, :timeline],
      output_format: :boolean
    }

    IO.puts("2️⃣ Evaluating timeline feasibility...")
    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step2)

    # Step 3: Resource analysis
    step3 = %{
      id: :resource_analysis,
      question: "Are resources sufficient for success?",
      analysis_type: :evaluation,
      context_required: [:resources, :complexity, :timeline],
      output_format: :analysis
    }

    IO.puts("3️⃣ Analyzing resource adequacy...")
    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step3)

    # Step 4: Synthesis
    step4 = %{
      id: :final_synthesis,
      question: "What's the overall project outlook?",
      analysis_type: :synthesis,
      context_required: [:complexity, :timeline, :resources, :stakeholders],
      output_format: :recommendation
    }

    IO.puts("4️⃣ Synthesizing final recommendation...")
    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step4)

    # Get final conclusion
    {:ok, conclusion} = Autogentic.Reasoning.Engine.conclude_reasoning_session(session_id)

    IO.puts("\n📋 Multi-Step Analysis Results:")
    IO.puts("Total steps: #{conclusion.total_steps}")
    IO.puts("Overall confidence: #{conclusion.confidence}")
    IO.puts("Reasoning quality: #{conclusion.reasoning_quality}")
    IO.puts("Recommendation: #{conclusion.recommendation}")
    IO.puts("Key insights: #{inspect(conclusion.key_insights, pretty: true)}")
  end

  defp decision_analysis_demo do
    IO.puts("\n3. 🎯 Decision Analysis with Agent Demo")
    IO.puts(String.duplicate("-", 30))

    # Start decision maker agent
    {:ok, agent_pid} = DecisionMakerAgent.start_link()
    IO.puts("🤖 Decision maker agent started")

    # Get initial state
    {state, _data} = Autogentic.get_agent_state(agent_pid)
    IO.puts("Initial state: #{state}")

    # Start analysis
    IO.puts("\n📊 Starting decision analysis...")
    GenStateMachine.cast(agent_pid, :analyze_request)
    Process.sleep(100)

    {state, data} = Autogentic.get_agent_state(agent_pid)
    IO.puts("Current state: #{state}")
    IO.puts("Context: #{inspect(data.context, pretty: true)}")

    # Complete analysis
    IO.puts("\n🔄 Completing analysis...")
    GenStateMachine.cast(agent_pid, :analysis_complete)
    Process.sleep(100)

    {state, data} = Autogentic.get_agent_state(agent_pid)
    IO.puts("Current state: #{state}")

    # Make decision
    IO.puts("\n✅ Making final decision...")
    GenStateMachine.cast(agent_pid, :decision_made)
    Process.sleep(100)

    {state, data} = Autogentic.get_agent_state(agent_pid)
    IO.puts("Final state: #{state}")
    IO.puts("Final context: #{inspect(data.context, pretty: true)}")

    # Cleanup
    GenStateMachine.stop(agent_pid)
  end
end

# Demonstrate knowledge base querying
defmodule KnowledgeBaseDemo do
  def run do
    IO.puts("\n4. 📚 Knowledge Base Demo")
    IO.puts(String.duplicate("-", 30))

    # Query about deployment
    IO.puts("🔍 Querying deployment knowledge...")
    deployment_knowledge = Autogentic.Reasoning.Engine.query_knowledge_base("deployment best practices")
    IO.puts("Deployment knowledge: #{inspect(deployment_knowledge, pretty: true)}")

    # Query about security
    IO.puts("\n🔒 Querying security knowledge...")
    security_knowledge = Autogentic.Reasoning.Engine.query_knowledge_base("security threats")
    IO.puts("Security knowledge: #{inspect(security_knowledge, pretty: true)}")

    # Query with context
    context = %{domain: :security, urgency: :high}
    IO.puts("\n🎯 Contextual security query...")
    contextual_result = Autogentic.Reasoning.Engine.query_knowledge_base("security assessment", context)
    IO.puts("Contextual result: #{inspect(contextual_result, pretty: true)}")
  end
end

# Main example runner
defmodule AdvancedReasoningExample do
  def run do
    ReasoningShowcase.run()
    KnowledgeBaseDemo.run()
  end
end

# Auto-run the example
AdvancedReasoningExample.run()
