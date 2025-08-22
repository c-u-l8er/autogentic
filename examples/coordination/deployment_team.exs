#!/usr/bin/env elixir

# Deployment Team - Multi-Agent Coordination Example
# This example shows how multiple agents work together to coordinate a software deployment

defmodule DeploymentCoordinator do
  use Autogentic.Agent, name: :deployment_coordinator

  agent :deployment_coordinator do
    capability [:orchestration, :decision_making]
    reasoning_style :analytical
    connects_to [:dev_agent, :qa_agent, :ops_agent]
    initial_state :planning
  end

  state :planning do
    # Coordinator is planning the deployment
  end

  state :coordinating do
    # Actively coordinating with team agents
  end

  state :monitoring do
    # Monitoring deployment progress
  end

  transition from: :planning, to: :coordinating, when_receives: :start_deployment do
    sequence do
      log(:info, "🚀 Starting deployment coordination")
      put_data(:deployment_id, generate_deployment_id())
      put_data(:started_at, DateTime.utc_now())
      broadcast_reasoning("Deployment initiated", [:dev_agent, :qa_agent, :ops_agent])
    end
  end

  transition from: :coordinating, to: :monitoring, when_receives: :all_agents_ready do
    sequence do
      log(:info, "📊 All agents ready, moving to monitoring")
      put_data(:monitoring_started, true)
      emit_event(:deployment_phase_change, %{phase: :monitoring})
    end
  end

  behavior :agent_status_update, triggers_on: [:agent_ready] do
    sequence do
      log(:debug, "Agent reported ready status")
      put_data(:ready_agents_count, get_ready_count() + 1)
    end
  end

  defp generate_deployment_id do
    "DEPLOY-#{System.unique_integer([:positive])}"
  end

  defp get_ready_count do
    # Simplified for example
    0
  end
end

defmodule DevAgent do
  use Autogentic.Agent, name: :dev_agent

  agent :dev_agent do
    capability [:code_validation, :build_management]
    reasoning_style :thorough
    connects_to [:deployment_coordinator]
    initial_state :idle
  end

  state :idle do
    # Waiting for deployment tasks
  end

  state :validating do
    # Validating code and running tests
  end

  state :building do
    # Building deployment artifacts
  end

  transition from: :idle, to: :validating, when_receives: :start_validation do
    sequence do
      log(:info, "🔍 Dev: Starting code validation")
      put_data(:validation_started, DateTime.utc_now())
    end
  end

  transition from: :validating, to: :building, when_receives: :validation_passed do
    sequence do
      log(:info, "✅ Dev: Validation passed, starting build")
      put_data(:build_started, DateTime.utc_now())
    end
  end

  behavior :deployment_notification, triggers_on: [:reasoning_shared] do
    sequence do
      log(:info, "📬 Dev: Received deployment notification")
      put_data(:coordinator_message_received, true)
    end
  end
end

defmodule QAAgent do
  use Autogentic.Agent, name: :qa_agent

  agent :qa_agent do
    capability [:testing, :quality_assurance]
    reasoning_style :critical
    connects_to [:deployment_coordinator]
    initial_state :standby
  end

  state :standby do
    # Ready for testing activities
  end

  state :testing do
    # Running comprehensive tests
  end

  transition from: :standby, to: :testing, when_receives: :run_tests do
    sequence do
      log(:info, "🧪 QA: Starting comprehensive testing")
      put_data(:test_suite_started, DateTime.utc_now())
      put_data(:tests_running, true)
    end
  end

  behavior :test_completion, triggers_on: [:tests_complete] do
    sequence do
      log(:info, "✅ QA: All tests passed")
      put_data(:all_tests_passed, true)
      broadcast_reasoning("Tests completed successfully", [:deployment_coordinator])
    end
  end
end

defmodule OpsAgent do
  use Autogentic.Agent, name: :ops_agent

  agent :ops_agent do
    capability [:infrastructure, :monitoring, :deployment]
    reasoning_style :practical
    connects_to [:deployment_coordinator]
    initial_state :monitoring
  end

  state :monitoring do
    # Monitoring infrastructure health
  end

  state :deploying do
    # Actively deploying to production
  end

  state :post_deployment do
    # Post-deployment verification
  end

  transition from: :monitoring, to: :deploying, when_receives: :begin_deployment do
    sequence do
      log(:info, "🚁 Ops: Beginning production deployment")
      put_data(:deployment_started, DateTime.utc_now())
      put_data(:target_environment, :production)
    end
  end

  transition from: :deploying, to: :post_deployment, when_receives: :deployment_complete do
    sequence do
      log(:info, "📈 Ops: Deployment complete, starting verification")
      put_data(:post_deploy_checks_started, true)
      emit_event(:deployment_completed, %{environment: :production})
    end
  end
end

# Example orchestration
defmodule DeploymentTeamExample do
  def run do
    IO.puts("🚀 Deployment Team Coordination Example")
    IO.puts(String.duplicate("=", 50))

    # Start all agents
    agents = start_agents()

    # Simulate deployment workflow
    simulate_deployment(agents)

    # Cleanup
    cleanup_agents(agents)

    IO.puts("\n✨ Deployment coordination example completed!")
  end

  defp start_agents do
    IO.puts("\n📋 Starting deployment team agents...")

    {:ok, coordinator} = DeploymentCoordinator.start_link()
    {:ok, dev} = DevAgent.start_link()
    {:ok, qa} = QAAgent.start_link()
    {:ok, ops} = OpsAgent.start_link()

    agents = %{
      coordinator: coordinator,
      dev: dev,
      qa: qa,
      ops: ops
    }

    IO.puts("✅ All agents started successfully")
    agents
  end

  defp simulate_deployment(agents) do
    IO.puts("\n🎬 Simulating deployment workflow...")

    # Step 1: Coordinator initiates deployment
    IO.puts("\n1️⃣ Coordinator: Initiating deployment...")
    GenStateMachine.cast(agents.coordinator, :start_deployment)
    Process.sleep(100)

    # Step 2: Dev agent starts validation
    IO.puts("\n2️⃣ Dev: Starting code validation...")
    GenStateMachine.cast(agents.dev, :start_validation)
    Process.sleep(200)

    # Step 3: Validation passes, start build
    IO.puts("\n3️⃣ Dev: Validation passed, building...")
    GenStateMachine.cast(agents.dev, :validation_passed)
    Process.sleep(150)

    # Step 4: QA runs tests
    IO.puts("\n4️⃣ QA: Running test suite...")
    GenStateMachine.cast(agents.qa, :run_tests)
    Process.sleep(300)

    # Step 5: Tests complete
    IO.puts("\n5️⃣ QA: Tests completed successfully")
    GenStateMachine.cast(agents.qa, :tests_complete)
    Process.sleep(100)

    # Step 6: Ops begins deployment
    IO.puts("\n6️⃣ Ops: Beginning production deployment...")
    GenStateMachine.cast(agents.ops, :begin_deployment)
    Process.sleep(250)

    # Step 7: Deployment completes
    IO.puts("\n7️⃣ Ops: Deployment completed!")
    GenStateMachine.cast(agents.ops, :deployment_complete)
    Process.sleep(100)

    # Show final states
    show_final_states(agents)
  end

  defp show_final_states(agents) do
    IO.puts("\n📊 Final Agent States:")
    IO.puts(String.duplicate("-", 30))

    Enum.each(agents, fn {name, pid} ->
      {state, data} = Autogentic.get_agent_state(pid)
      IO.puts("#{String.capitalize(to_string(name))}: #{state}")
      if map_size(data.context) > 0 do
        IO.puts("  Context: #{inspect(data.context, pretty: true, limit: 3)}")
      end
    end)
  end

  defp cleanup_agents(agents) do
    IO.puts("\n🧹 Cleaning up agents...")
    Enum.each(agents, fn {_name, pid} ->
      GenStateMachine.stop(pid)
    end)
  end
end

# Auto-run the example
DeploymentTeamExample.run()
