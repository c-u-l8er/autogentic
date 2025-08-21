# Multi-Agent Software Deployment Demo
# This demonstrates planning, security analysis, and execution agents
# working together with full chain-of-thought reasoning

defmodule DeploymentPlannerAgent do
  use AgentFSM
  agent :deployment_planner do
    capabilities [:planning, :risk_assessment, :resource_allocation]
    memory_size 100
    connects_to [:security_agent, :executor_agent, :monitor_agent]
    initial_state :idle
  end

  state :idle do
    on_enter: fn ->
      IO.puts("🤖 [PLANNER] Ready to plan deployments")
    end
  end

  state :analyzing do
    on_enter: fn ->
      IO.puts("🤖 [PLANNER] Analyzing deployment requirements...")
    end
  end

  state :planning do
    on_enter: fn ->
      IO.puts("🤖 [PLANNER] Creating deployment plan...")
    end
  end

  transition from: :idle, to: :analyzing do
    when_receives :deployment_request, from: :any

    reason_about "Should I start analyzing this deployment request?"
    reasoning_steps do
      step :assess_request_clarity, "Is the deployment request clear and complete?"
      step :check_system_capacity, "Do we have capacity for this deployment?"
      step :evaluate_timing, "Is this a good time for deployment?"
      step :consider_dependencies, "Are there any blocking dependencies?"
    end

    action fn data ->
      IO.puts("🧠 [PLANNER REASONING] Starting analysis...")
      %{data | current_request: data.incoming_request}
    end
  end

  transition from: :analyzing, to: :planning do
    when_receives :analysis_complete, from: :self

    reason_about "Should I proceed with creating a deployment plan?"
    reasoning_steps do
      step :validate_analysis, "Are the analysis results sufficient?"
      step :identify_risks, "What are the main risks identified?"
      step :plan_complexity, "How complex will this deployment be?"
    end

    action &create_deployment_plan/1
    notify [:security_agent], :plan_ready_for_review
  end

  chain_of_thought :deployment_planning do
    triggers_on [:complex_deployment, :high_risk_deployment]
    in_states [:planning]

    reasoning_steps do
      step :analyze_architecture, "What is the current system architecture?"
      step :identify_components, "Which components need to be deployed?"
      step :sequence_operations, "In what order should operations occur?"
      step :plan_rollback, "How can we rollback if something goes wrong?"
      step :estimate_timeline, "How long will each phase take?"
      step :allocate_resources, "What resources are needed for each phase?"
    end

    use_memory true
    reasoning_history_limit 10

    broadcast_reasoning_to [:security_agent, :monitor_agent]
    reasoning_transparency :full
  end

  behavior :adaptive_planning do
    triggers_on [:feedback_received, :deployment_failed]
    in_states [:any]

    use_reasoning :learning_analysis
    reasoning_prompt "What went wrong and how can I improve my planning?"

    action fn data, event ->
      IO.puts("🧠 [PLANNER LEARNING] Analyzing feedback: #{event.payload.message}")
      updated_knowledge = Map.update(data.knowledge || %{}, :lessons_learned, [], fn lessons ->
        [event.payload | lessons] |> Enum.take(20)
      end)
      %{data | knowledge: updated_knowledge}
    end
  end

  defp create_deployment_plan(data) do
    IO.puts("🤖 [PLANNER] Creating detailed deployment plan...")

    plan = %{
      phases: [:preparation, :deployment, :verification, :cleanup],
      timeline: "45 minutes",
      risk_level: :medium,
      rollback_plan: true
    }

    %{data | deployment_plan: plan}
  end
end

defmodule SecurityAnalysisAgent do
  use AgentFSM

  agent :security_agent do
    capabilities [:security_analysis, :threat_detection, :compliance_check]
    connects_to [:deployment_planner, :executor_agent, :monitor_agent]
    initial_state :monitoring
  end

  state :monitoring do
    on_enter: fn ->
      IO.puts("🛡️  [SECURITY] Monitoring for security reviews...")
    end
  end

  state :analyzing_security do
    on_enter: fn ->
      IO.puts("🛡️  [SECURITY] Performing security analysis...")
    end
  end

  transition from: :monitoring, to: :analyzing_security do
    when_receives :plan_ready_for_review, from: :deployment_planner

    reason_about "Should I perform a security analysis on this deployment plan?"
    reasoning_steps do
      step :assess_security_impact, "What are the security implications?"
      step :check_compliance, "Does this meet our security policies?"
      step :identify_vulnerabilities, "Are there potential security holes?"
    end

    action &start_security_analysis/1
  end

  chain_of_thought :security_analysis do
    triggers_on [:plan_ready_for_review, :security_concern_detected]
    in_states [:analyzing_security]

    reasoning_steps do
      step :threat_modeling, "What threats could this deployment introduce?"
      step :access_control_review, "Are access controls properly configured?"
      step :data_protection_check, "Is sensitive data properly protected?"
      step :network_security_analysis, "Are network security measures adequate?"
      step :compliance_verification, "Does this meet regulatory requirements?"
      step :risk_scoring, "What is the overall security risk score?"
    end

    broadcast_reasoning_to [:deployment_planner, :monitor_agent]
    reasoning_transparency :summary
  end

  defp start_security_analysis(data) do
    IO.puts("🧠 [SECURITY REASONING] Analyzing security implications...")

    # Simulate security analysis
    Process.send_after(self(), {:security_analysis_complete, :approved}, 2000)

    data
  end
end

defmodule ExecutorAgent do
  use AgentFSM

  agent :executor_agent do
    capabilities [:deployment_execution, :system_management, :monitoring]
    connects_to [:deployment_planner, :security_agent, :monitor_agent]
    initial_state :ready
  end

  state :ready do
    on_enter: fn ->
      IO.puts("⚡ [EXECUTOR] Ready to execute deployments")
    end
  end

  state :executing do
    on_enter: fn ->
      IO.puts("⚡ [EXECUTOR] Executing deployment...")
    end
  end

  transition from: :ready, to: :executing do
    when_receives :execute_deployment, from: :deployment_planner

    reason_about "Should I execute this deployment now?"
    reasoning_steps do
      step :verify_security_approval, "Has security approved this deployment?"
      step :check_system_health, "Are all systems healthy?"
      step :validate_resources, "Are required resources available?"
      step :confirm_rollback_ready, "Is rollback procedure ready?"
    end

    action &execute_deployment/1
  end

  behavior :execution_monitoring do
    triggers_on [:execution_progress, :execution_error]
    in_states [:executing]

    use_reasoning :execution_analysis
    reasoning_prompt "How is the execution progressing and what should I do next?"

    action fn data, event ->
      IO.puts("⚡ [EXECUTOR] Progress update: #{event.payload.status}")

      case event.payload.status do
        :error ->
          IO.puts("🚨 [EXECUTOR] Error detected, initiating rollback...")
          GenStateMachine.cast(self(), %{type: :initiate_rollback})
        :success ->
          IO.puts("✅ [EXECUTOR] Deployment completed successfully!")
        _ ->
          IO.puts("📊 [EXECUTOR] Continuing execution...")
      end

      data
    end
  end

  defp execute_deployment(data) do
    IO.puts("🧠 [EXECUTOR REASONING] Planning execution steps...")

    # Simulate deployment phases
    spawn(fn ->
      phases = [
        {:preparation, "Preparing deployment environment"},
        {:deployment, "Deploying application components"},
        {:verification, "Verifying deployment success"},
        {:cleanup, "Cleaning up temporary resources"}
      ]

      Enum.each(phases, fn {phase, description} ->
        Process.sleep(1500)
        IO.puts("⚡ [EXECUTOR] #{description}...")

        GenStateMachine.cast(:executor_agent, %{
          type: :execution_progress,
          payload: %{phase: phase, status: :in_progress}
        })
      end)

      Process.sleep(1000)
      GenStateMachine.cast(:executor_agent, %{
        type: :execution_progress,
        payload: %{phase: :complete, status: :success}
      })
    end)

    data
  end
end

defmodule MonitorAgent do
  use AgentFSM

  agent :monitor_agent do
    capabilities [:system_monitoring, :alerting, :coordination]
    connects_to [:deployment_planner, :security_agent, :executor_agent]
    initial_state :observing
  end

  state :observing do
    on_enter: fn ->
      IO.puts("👁️  [MONITOR] Observing system state and agent coordination...")
    end
  end

  behavior :coordination_oversight do
    triggers_on [:reasoning_shared, :plan_ready_for_review, :execution_progress]
    in_states [:observing]

    action fn data, event ->
      case event.type do
        :reasoning_shared ->
          IO.puts("👁️  [MONITOR] Received reasoning from #{inspect(event.from)}")
          IO.puts("    💭 Conclusion: #{event.reasoning.conclusion}")

        :plan_ready_for_review ->
          IO.puts("👁️  [MONITOR] Deployment plan created, security review in progress...")

        :execution_progress ->
          IO.puts("👁️  [MONITOR] Tracking execution: #{event.payload.phase} - #{event.payload.status}")
      end

      data
    end
  end

  coordination :deployment_consensus do
    participants [:deployment_planner, :security_agent, :executor_agent]
    protocol :unanimous_approval

    when_all_agree :deployment_ready do
      action fn data ->
        IO.puts("👁️  [MONITOR] 🎉 All agents agree - deployment approved!")
        GenStateMachine.cast(:executor_agent, %{
          type: :execute_deployment,
          from: :monitor_agent
        })
        data
      end
      timeout 10000
    end

    when_conflict :deployment_ready do
      fallback fn data ->
        IO.puts("👁️  [MONITOR] ⚠️  Agents disagree on deployment readiness")
        IO.puts("    Escalating to human review...")
        data
      end
    end
  end
end

# Demo Runner
defmodule DeploymentDemo do
  def run do
    IO.puts("\n" <> String.duplicate("=", 60))
    IO.puts("🚀 MULTI-AGENT DEPLOYMENT SYSTEM DEMO")
    IO.puts("   Chain of Thought Reasoning Enabled")
    IO.puts(String.duplicate("=", 60) <> "\n")

    # Start the agent network
    {:ok, _} = start_agent_network()

    # Wait for agents to initialize
    Process.sleep(500)

    IO.puts("📋 [DEMO] Initiating deployment request...\n")

    # Send deployment request
    deployment_request = %{
      type: :deployment_request,
      from: :human_operator,
      payload: %{
        application: "web-service-v2.1.0",
        environment: :production,
        urgency: :normal,
        estimated_impact: :medium
      },
      timestamp: DateTime.utc_now()
    }

    GenStateMachine.cast(:deployment_planner, deployment_request)

    # Let the demo run
    Process.sleep(8000)

    IO.puts("\n📋 [DEMO] Triggering security analysis completion...")
    send(:security_agent, {:security_analysis_complete, :approved})

    # Wait for coordination and execution
    Process.sleep(10000)

    IO.puts("\n" <> String.duplicate("=", 60))
    IO.puts("✅ DEMO COMPLETE - All agents coordinated successfully!")
    IO.puts("   Chain of thought reasoning guided every decision")
    IO.puts(String.duplicate("=", 60))
  end

  defp start_agent_network do
    children = [
      {DeploymentPlannerAgent, [name: :deployment_planner]},
      {SecurityAnalysisAgent, [name: :security_agent]},
      {ExecutorAgent, [name: :executor_agent]},
      {MonitorAgent, [name: :monitor_agent]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

# Expected stdout when running DeploymentDemo.run():
"""
============================================================
🚀 MULTI-AGENT DEPLOYMENT SYSTEM DEMO
   Chain of Thought Reasoning Enabled
============================================================

🤖 [PLANNER] Ready to plan deployments
🛡️  [SECURITY] Monitoring for security reviews...
⚡ [EXECUTOR] Ready to execute deployments
👁️  [MONITOR] Observing system state and agent coordination...

📋 [DEMO] Initiating deployment request...

🧠 [PLANNER REASONING] Starting analysis...
🤖 [PLANNER] Analyzing deployment requirements...
🧠 [PLANNER REASONING] Should I start analyzing this deployment request?
    Step 1: assess_request_clarity - Is the deployment request clear and complete?
    Result: Yes, request includes app version, environment, and impact level

    Step 2: check_system_capacity - Do we have capacity for this deployment?
    Result: System capacity is adequate for medium impact deployment

    Step 3: evaluate_timing - Is this a good time for deployment?
    Result: Normal urgency allows for proper planning and execution

    Step 4: consider_dependencies - Are there any blocking dependencies?
    Result: No blocking dependencies identified

    Conclusion: Proceeding with deployment analysis

🤖 [PLANNER] Creating deployment plan...
🧠 [PLANNER REASONING] Should I proceed with creating a deployment plan?
    Step 1: validate_analysis - Are the analysis results sufficient?
    Result: Analysis complete, all requirements validated

    Step 2: identify_risks - What are the main risks identified?
    Result: Medium risk level, standard production deployment

    Step 3: plan_complexity - How complex will this deployment be?
    Result: Standard complexity, 4 phase deployment recommended

    Conclusion: Creating detailed deployment plan

🤖 [PLANNER] Creating detailed deployment plan...
🛡️  [SECURITY] Performing security analysis...
👁️  [MONITOR] Deployment plan created, security review in progress...

🧠 [SECURITY REASONING] Analyzing security implications...
🧠 [SECURITY REASONING] Should I perform a security analysis on this deployment plan?
    Step 1: assess_security_impact - What are the security implications?
    Result: Standard web service deployment, moderate security review needed

    Step 2: check_compliance - Does this meet our security policies?
    Result: Deployment follows standard security procedures

    Step 3: identify_vulnerabilities - Are there potential security holes?
    Result: No obvious vulnerabilities in deployment plan

    Conclusion: Proceeding with detailed security analysis

🧠 [SECURITY REASONING] Chain of Thought: security_analysis
    Step 1: threat_modeling - What threats could this deployment introduce?
    Result: Standard web application threats, mitigated by existing controls

    Step 2: access_control_review - Are access controls properly configured?
    Result: RBAC configured correctly, principle of least privilege applied

    Step 3: data_protection_check - Is sensitive data properly protected?
    Result: Encryption at rest and in transit configured

    Step 4: network_security_analysis - Are network security measures adequate?
    Result: Firewall rules and network segmentation properly configured

    Step 5: compliance_verification - Does this meet regulatory requirements?
    Result: SOC2 and GDPR compliance requirements satisfied

    Step 6: risk_scoring - What is the overall security risk score?
    Result: Risk score: 3/10 (Low risk, approved for deployment)

👁️  [MONITOR] Received reasoning from :security_agent
    💭 Conclusion: Risk score: 3/10 (Low risk, approved for deployment)

📋 [DEMO] Triggering security analysis completion...

👁️  [MONITOR] 🎉 All agents agree - deployment approved!

🧠 [EXECUTOR REASONING] Should I execute this deployment now?
    Step 1: verify_security_approval - Has security approved this deployment?
    Result: Security analysis complete, risk score 3/10, approved

    Step 2: check_system_health - Are all systems healthy?
    Result: All system health checks passing

    Step 3: validate_resources - Are required resources available?
    Result: CPU, memory, and storage resources available

    Step 4: confirm_rollback_ready - Is rollback procedure ready?
    Result: Automated rollback configured and tested

    Conclusion: All pre-conditions met, executing deployment

⚡ [EXECUTOR] Executing deployment...
🧠 [EXECUTOR REASONING] Planning execution steps...

⚡ [EXECUTOR] Preparing deployment environment...
⚡ [EXECUTOR] Progress update: in_progress
👁️  [MONITOR] Tracking execution: preparation - in_progress

⚡ [EXECUTOR] Deploying application components...
⚡ [EXECUTOR] Progress update: in_progress
👁️  [MONITOR] Tracking execution: deployment - in_progress

⚡ [EXECUTOR] Verifying deployment success...
⚡ [EXECUTOR] Progress update: in_progress
👁️  [MONITOR] Tracking execution: verification - in_progress

⚡ [EXECUTOR] Cleaning up temporary resources...
⚡ [EXECUTOR] Progress update: in_progress
👁️  [MONITOR] Tracking execution: cleanup - in_progress

✅ [EXECUTOR] Deployment completed successfully!
⚡ [EXECUTOR] Progress update: success
👁️  [MONITOR] Tracking execution: complete - success

============================================================
✅ DEMO COMPLETE - All agents coordinated successfully!
   Chain of thought reasoning guided every decision
============================================================
"""
