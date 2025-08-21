# Autogentic v2.0 Complete Agent Implementations
# ExecutorAgent and MonitorAgent with enhanced effects integration

defmodule ExecutorAgentV2 do
  use AutogenticV2.Agent, name: :executor_agent

  agent :executor_agent do
    capability [:deployment_execution, :system_management, :monitoring, :rollback_management]
    reasoning_style :analytical
    connects_to [:deployment_planner, :security_agent, :monitor_agent]
    initial_state :ready
  end

  state :ready do
    on_enter: fn ->
      log(:info, "⚡ [EXECUTOR] Advanced execution system ready")
    end
  end

  state :executing do
    on_enter: fn ->
      log(:info, "⚡ [EXECUTOR] Intelligent execution in progress")
    end
  end

  state :monitoring_execution do
    on_enter: fn ->
      log(:info, "⚡ [EXECUTOR] Monitoring execution with AI oversight")
    end
  end

  state :rollback_initiated do
    on_enter: fn ->
      log(:warning, "⚡ [EXECUTOR] Intelligent rollback initiated")
    end
  end

  # Enhanced execution with comprehensive effects
  transition from: :ready, to: :executing, when_receives: :execute_deployment do
    sequence do
      log(:info, "🧠 [EXECUTOR] Analyzing execution readiness...")

      # Multi-dimensional execution readiness assessment
      reason "Should I execute this deployment now?" do
        [
          %{
            id: :verify_security_approval,
            question: "Has security provided clear approval with acceptable risk level?",
            analysis_type: :evaluation,
            context_required: [:security_results, :risk_assessment],
            output_format: :boolean
          },
          %{
            id: :assess_system_health,
            question: "Are all target systems healthy and ready?",
            analysis_type: :assessment,
            context_required: [:system_metrics, :health_checks, :dependency_status],
            output_format: :analysis
          },
          %{
            id: :validate_resources,
            question: "Are all required resources available and allocated?",
            analysis_type: :evaluation,
            context_required: [:resource_allocation, :capacity_planning],
            output_format: :boolean
          },
          %{
            id: :confirm_rollback_readiness,
            question: "Is the rollback mechanism tested and ready?",
            analysis_type: :assessment,
            context_required: [:rollback_plan, :backup_status],
            output_format: :analysis
          },
          %{
            id: :evaluate_timing,
            question: "Is this the optimal time for execution?",
            analysis_type: :consideration,
            context_required: [:deployment_window, :business_hours, :traffic_patterns],
            output_format: :recommendation
          }
        ]
      end

      # Advanced execution planning with AI
      coordinate [
        %{
          id: :execution_planner,
          role: "Deployment execution specialist",
          model: "gpt-4",
          capabilities: [:execution_planning, :risk_mitigation, :timing_optimization],
          reasoning_style: :analytical
        },
        %{
          id: :rollback_strategist,
          role: "Rollback planning expert",
          model: "claude-3",
          capabilities: [:rollback_planning, :recovery_strategies, :data_protection],
          reasoning_style: :critical
        },
        %{
          id: :monitoring_coordinator,
          role: "Execution monitoring specialist",
          model: "gemini-pro",
          capabilities: [:real_time_monitoring, :anomaly_detection, :performance_analysis],
          reasoning_style: :synthetic
        }
      ], type: :parallel, timeout: 45_000

      # Generate comprehensive execution plan
      call_llm(
        provider: :openai,
        model: "gpt-4",
        role: "Execution orchestration expert",
        system: """
        You are an expert at orchestrating complex deployment executions.
        Create detailed execution plans with monitoring, validation, and recovery steps.
        """,
        prompt: build_execution_plan_prompt(),
        temperature: 0.2,
        max_tokens: 3000
      )

      put_data :execution_plan, get_result()

      # Execute with comprehensive monitoring
      emit_event :execution_started, %{
        plan: get_data(:execution_plan),
        estimated_duration: get_data(:estimated_duration),
        rollback_ready: true
      }
    end
  end

  # Advanced execution monitoring with real-time adaptation
  behavior :intelligent_execution_monitoring, triggers_on: [:execution_progress, :execution_error, :performance_anomaly] do
    sequence do
      log(:info, "🧠 [EXECUTOR] Analyzing execution progress with AI...")

      reason "How is the execution progressing and what should I do next?" do
        [
          %{
            id: :analyze_progress,
            question: "What is the current execution status and health?",
            analysis_type: :assessment,
            context_required: [:current_metrics, :progress_indicators, :system_health],
            output_format: :analysis
          },
          %{
            id: :detect_anomalies,
            question: "Are there any concerning patterns or anomalies?",
            analysis_type: :evaluation,
            context_required: [:performance_data, :error_logs, :baseline_metrics],
            output_format: :analysis
          },
          %{
            id: :predict_outcome,
            question: "What is the predicted execution outcome based on current trends?",
            analysis_type: :prediction,
            context_required: [:progress_trends, :historical_patterns, :current_trajectory],
            output_format: :analysis
          },
          %{
            id: :determine_action,
            question: "What action should I take based on this analysis?",
            analysis_type: :synthesis,
            context_required: [:progress_analysis, :anomaly_detection, :outcome_prediction],
            output_format: :recommendation
          }
        ]
      end

      # Real-time decision making based on progress analysis
      case get_data(:execution_status) do
        %{status: :error, severity: severity} when severity in [:high, :critical] ->
          sequence do
            log(:error, "🚨 [EXECUTOR] Critical error detected, initiating intelligent rollback")

            # Coordinate emergency response
            coordinate [
              %{
                id: :incident_commander,
                role: "Incident response commander",
                model: "gpt-4",
                capabilities: [:incident_management, :emergency_coordination, :damage_assessment],
                reasoning_style: :critical
              }
            ], type: :consensus, consensus_threshold: 0.9

            emit_event :initiate_emergency_rollback, %{
              reason: get_data(:error_reason),
              severity: severity,
              rollback_strategy: get_data(:recommended_rollback)
            }
          end

        %{status: :warning, trend: :degrading} ->
          sequence do
            log(:warning, "⚠️ [EXECUTOR] Performance degradation detected, adjusting execution")

            # Adaptive execution adjustment
            call_llm(
              provider: :anthropic,
              model: "claude-3",
              role: "Execution optimization specialist",
              prompt: "Adjust execution parameters to address performance degradation: #{get_data(:degradation_analysis)}",
              temperature: 0.3
            )

            put_data :execution_adjustments, get_result()
            emit_event :execution_adjusted, get_data(:execution_adjustments)
          end

        %{status: :success} ->
          sequence do
            log(:info, "✅ [EXECUTOR] Execution completed successfully!")

            # Success analysis and learning
            reason "What made this execution successful?" do
              [
                %{
                  id: :success_factors,
                  question: "What key factors contributed to execution success?",
                  analysis_type: :synthesis,
                  context_required: [:execution_metrics, :decision_history, :system_performance],
                  output_format: :analysis
                },
                %{
                  id: :improvement_opportunities,
                  question: "What could be improved for future executions?",
                  analysis_type: :consideration,
                  context_required: [:performance_analysis, :resource_utilization, :timing_analysis],
                  output_format: :recommendation
                }
              ]
            end

            # Store learnings for future executions
            learn_from_outcome "deployment_execution", %{
              success: true,
              execution_time: get_data(:execution_duration),
              performance_metrics: get_data(:final_metrics),
              success_factors: get_data(:success_analysis),
              context: get_data(:execution_context)
            }

            emit_event :execution_completed_successfully, %{
              metrics: get_data(:final_metrics),
              learnings: get_data(:success_analysis)
            }
          end

        %{status: :in_progress, progress: progress} when progress >= 0.8 ->
          sequence do
            log(:info, "📊 [EXECUTOR] Execution nearing completion (#{Float.round(progress * 100, 1)}%)")

            # Pre-completion validation
            parallel do
              call_llm(
                provider: :google,
                model: "gemini-pro",
                prompt: "Validate execution completion readiness: #{get_data(:completion_metrics)}"
              )

              # Prepare post-execution monitoring
              call_llm(
                provider: :openai,
                model: "gpt-4",
                prompt: "Generate post-deployment monitoring strategy: #{get_data(:deployment_plan)}"
              )
            end

            put_data :completion_validation, get_result()
          end

        _ ->
          sequence do
            log(:debug, "📊 [EXECUTOR] Execution progressing normally")

            # Standard progress monitoring
            put_data :last_progress_check, DateTime.utc_now()
            broadcast_reasoning "Execution progressing as planned", [:monitor_agent, :deployment_planner]
          end
      end
    end
  end

  # Intelligent rollback coordination
  behavior :intelligent_rollback_management, triggers_on: [:initiate_rollback, :initiate_emergency_rollback] do
    sequence do
      log(:warning, "🔄 [EXECUTOR] Initiating intelligent rollback sequence...")

      reason "How should I execute this rollback to minimize impact?" do
        [
          %{
            id: :assess_rollback_scope,
            question: "What is the scope and complexity of this rollback?",
            analysis_type: :assessment,
            context_required: [:deployment_state, :affected_systems, :data_changes],
            output_format: :analysis
          },
          %{
            id: :evaluate_rollback_risks,
            question: "What are the risks and potential impacts of rollback?",
            analysis_type: :evaluation,
            context_required: [:system_dependencies, :data_integrity, :service_availability],
            output_format: :analysis
          },
          %{
            id: :optimize_rollback_strategy,
            question: "What is the optimal rollback strategy for this situation?",
            analysis_type: :synthesis,
            context_required: [:rollback_options, :impact_analysis, :recovery_time_objectives],
            output_format: :recommendation
          }
        ]
      end

      # Coordinate rollback execution
      coordinate [
        %{
          id: :rollback_coordinator,
          role: "Rollback execution specialist",
          model: "gpt-4",
          capabilities: [:rollback_orchestration, :data_recovery, :service_restoration],
          reasoning_style: :analytical
        },
        %{
          id: :impact_assessor,
          role: "Impact assessment specialist",
          model: "claude-3",
          capabilities: [:impact_analysis, :risk_assessment, :stakeholder_communication],
          reasoning_style: :critical
        }
      ], type: :sequential, timeout: 60_000

      # Execute rollback phases
      sequence do
        log(:info, "⚡ [EXECUTOR] Phase 1: Stopping affected services")

        # Phase 1: Service isolation
        parallel do
          call_llm(
            provider: :openai,
            model: "gpt-4",
            prompt: "Generate service shutdown sequence: #{get_data(:affected_services)}"
          )

          # Notify stakeholders
          emit_event :rollback_phase_started, %{
            phase: :service_isolation,
            estimated_duration: get_data(:phase_duration),
            impact_level: get_data(:impact_level)
          }
        end

        log(:info, "⚡ [EXECUTOR] Phase 2: Data rollback and recovery")

        # Phase 2: Data restoration
        with_fallback(
          call_llm(
            provider: :anthropic,
            model: "claude-3",
            prompt: "Execute data rollback strategy: #{get_data(:data_rollback_plan)}"
          )
        ) do
          escalate_to_human(
            priority: :critical,
            reason: "Data rollback requires manual intervention",
            context: get_data(:rollback_context)
          )
        end

        log(:info, "⚡ [EXECUTOR] Phase 3: Service restoration and validation")

        # Phase 3: Service restoration
        coordinate [
          %{
            id: :service_restorer,
            role: "Service restoration specialist",
            model: "gemini-pro",
            capabilities: [:service_management, :health_validation, :performance_verification],
            reasoning_style: :analytical
          }
        ]

        # Final rollback validation
        reason "Is the rollback complete and successful?" do
          [
            %{
              id: :validate_rollback_completion,
              question: "Are all systems restored to the previous stable state?",
              analysis_type: :evaluation,
              context_required: [:system_status, :service_health, :data_integrity],
              output_format: :boolean
            },
            %{
              id: :assess_residual_impact,
              question: "Are there any remaining impacts or issues?",
              analysis_type: :assessment,
              context_required: [:system_metrics, :error_logs, :user_reports],
              output_format: :analysis
            }
          ]
        end

        # Store rollback learnings
        learn_from_outcome "rollback_execution", %{
          success: get_data(:rollback_successful),
          rollback_reason: get_data(:original_failure_reason),
          rollback_duration: get_data(:rollback_duration),
          lessons_learned: get_data(:rollback_analysis),
          context: get_data(:rollback_context)
        }

        emit_event :rollback_completed, %{
          success: get_data(:rollback_successful),
          final_status: get_data(:system_status),
          next_steps: get_data(:recovery_recommendations)
        }
      end
    end
  end

  # Helper functions for execution
  defp build_execution_plan_prompt do
    """
    Create a comprehensive deployment execution plan based on:

    Deployment Context: #{inspect(get_data(:deployment_context))}
    Security Analysis: #{inspect(get_data(:security_results))}
    System Health: #{inspect(get_data(:system_health))}
    Resource Status: #{inspect(get_data(:resource_status))}

    The plan should include:
    1. Detailed execution phases with timing
    2. Monitoring checkpoints and success criteria
    3. Risk mitigation steps at each phase
    4. Rollback triggers and procedures
    5. Communication and notification strategy
    6. Post-deployment validation steps

    Format as structured JSON with clear phases, steps, and validation points.
    """
  end
end

defmodule MonitorAgentV2 do
  use AutogenticV2.Agent, name: :monitor_agent

  agent :monitor_agent do
    capability [:system_monitoring, :alerting, :coordination, :analytics, :pattern_recognition]
    reasoning_style :synthetic
    connects_to [:deployment_planner, :security_agent, :executor_agent]
    initial_state :observing
  end

  state :observing do
    on_enter: fn ->
      log(:info, "👁️  [MONITOR] Advanced AI monitoring and coordination active")
    end
  end

  state :analyzing_patterns do
    on_enter: fn ->
      log(:info, "👁️  [MONITOR] Deep pattern analysis in progress")
    end
  end

  state :coordinating_response do
    on_enter: fn ->
      log(:info, "👁️  [MONITOR] Coordinating intelligent system response")
    end
  end

  # Comprehensive system monitoring with AI analysis
  behavior :intelligent_system_monitoring, triggers_on: [:system_event, :performance_anomaly, :agent_coordination] do
    sequence do
      log(:debug, "👁️  [MONITOR] Processing system event with AI analysis")

      reason "What does this system event indicate and how should I respond?" do
        [
          %{
            id: :event_significance,
            question: "What is the significance of this event in the system context?",
            analysis_type: :assessment,
            context_required: [:event_data, :system_state, :historical_patterns],
            output_format: :analysis
          },
          %{
            id: :pattern_recognition,
            question: "Does this event fit any known patterns or indicate emerging trends?",
            analysis_type: :consideration,
            context_required: [:event_history, :pattern_database, :correlation_data],
            output_format: :analysis
          },
          %{
            id: :impact_assessment,
            question: "What is the potential impact on system performance and reliability?",
            analysis_type: :evaluation,
            context_required: [:system_dependencies, :performance_baselines, :risk_factors],
            output_format: :analysis
          },
          %{
            id: :response_strategy,
            question: "What is the optimal response strategy for this situation?",
            analysis_type: :synthesis,
            context_required: [:event_analysis, :impact_assessment, :available_responses],
            output_format: :recommendation
          }
        ]
      end

      # Event-specific response logic
      case get_data(:event_type) do
        :reasoning_shared ->
          sequence do
            log(:info, "👁️  [MONITOR] Received reasoning from #{get_data(:source_agent)}")

            # Analyze reasoning quality and insights
            call_llm(
              provider: :anthropic,
              model: "claude-3",
              role: "Reasoning quality analyst",
              system: """
              You analyze the quality and insights from agent reasoning.
              Evaluate logical consistency, completeness, and actionable insights.
              """,
              prompt: "Analyze reasoning quality: #{inspect(get_data(:reasoning_data))}",
              temperature: 0.3
            )

            put_data :reasoning_analysis, get_result()

            # Extract and store valuable insights
            parallel do
              # Store insights for future reference
              learn_from_outcome "reasoning_analysis", %{
                source_agent: get_data(:source_agent),
                reasoning_quality: get_data(:reasoning_analysis),
                insights_extracted: get_data(:key_insights),
                context: get_data(:reasoning_context)
              }

              # Share insights with relevant agents if significant
              case get_data(:reasoning_analysis) do
                %{quality_score: score} when score >= 0.8 ->
                  broadcast_reasoning "High-quality reasoning insights available", get_connected_agents()
                _ ->
                  log(:debug, "Standard reasoning quality, no broadcast needed")
              end
            end
          end

        :plan_ready_for_review ->
          sequence do
            log(:info, "👁️  [MONITOR] Deployment plan ready, initiating comprehensive review")

            # Coordinate comprehensive plan review
            coordinate [
              %{
                id: :plan_reviewer,
                role: "Deployment plan review specialist",
                model: "gpt-4",
                capabilities: [:plan_analysis, :risk_assessment, :quality_evaluation],
                reasoning_style: :critical
              },
              %{
                id: :stakeholder_analyst,
                role: "Stakeholder impact analyst",
                model: "claude-3",
                capabilities: [:stakeholder_analysis, :communication_planning, :expectation_management],
                reasoning_style: :synthetic
              }
            ], type: :parallel, timeout: 90_000

            # Generate comprehensive plan assessment
            reason "Should this deployment plan be approved for execution?" do
              [
                %{
                  id: :plan_completeness,
                  question: "Is the deployment plan complete and well-structured?",
                  analysis_type: :evaluation,
                  context_required: [:plan_details, :completeness_criteria, :best_practices],
                  output_format: :analysis
                },
                %{
                  id: :risk_adequacy,
                  question: "Are risks adequately identified and mitigated?",
                  analysis_type: :assessment,
                  context_required: [:risk_analysis, :mitigation_strategies, :residual_risks],
                  output_format: :analysis
                },
                %{
                  id: :stakeholder_readiness,
                  question: "Are all stakeholders properly informed and prepared?",
                  analysis_type: :evaluation,
                  context_required: [:stakeholder_list, :communication_plan, :approval_status],
                  output_format: :boolean
                }
              ]
            end

            put_data :plan_assessment, get_result()

            # Make recommendation based on comprehensive analysis
            case get_data(:plan_assessment) do
              %{overall_score: score} when score >= 0.85 ->
                emit_event :plan_approved_for_execution, %{
                  assessment: get_data(:plan_assessment),
                  confidence: get_data(:assessment_confidence),
                  monitor_strategy: get_data(:recommended_monitoring)
                }
              %{overall_score: score} when score >= 0.7 ->
                emit_event :plan_approved_with_conditions, %{
                  assessment: get_data(:plan_assessment),
                  conditions: get_data(:approval_conditions),
                  required_improvements: get_data(:improvement_requirements)
                }
              _ ->
                emit_event :plan_requires_revision, %{
                  assessment: get_data(:plan_assessment),
                  critical_issues: get_data(:critical_issues),
                  revision_recommendations: get_data(:revision_requirements)
                }
            end
          end

        :execution_progress ->
          sequence do
            log(:info, "👁️  [MONITOR] Tracking execution: #{get_data(:phase)} - #{get_data(:status)}")

            # Real-time execution analysis
            call_llm(
              provider: :google,
              model: "gemini-pro",
              role: "Execution monitoring specialist",
              system: """
              You monitor deployment executions in real-time, identifying patterns,
              anomalies, and optimization opportunities.
              """,
              prompt: build_execution_monitoring_prompt(),
              temperature: 0.2
            )

            put_data :execution_analysis, get_result()

            # Predictive analysis for execution outcome
            reason "What is the predicted execution outcome and what actions should be taken?" do
              [
                %{
                  id: :execution_health,
                  question: "What is the current health and trajectory of the execution?",
                  analysis_type: :assessment,
                  context_required: [:execution_metrics, :progress_indicators, :performance_data],
                  output_format: :analysis
                },
                %{
                  id: :anomaly_detection,
                  question: "Are there any concerning anomalies or deviations?",
                  analysis_type: :evaluation,
                  context_required: [:baseline_metrics, :current_performance, :historical_patterns],
                  output_format: :analysis
                },
                %{
                  id: :intervention_assessment,
                  question: "Is any intervention or adjustment needed?",
                  analysis_type: :synthesis,
                  context_required: [:health_analysis, :anomaly_results, :intervention_options],
                  output_format: :recommendation
                }
              ]
            end

            # Store execution intelligence for learning
            learn_from_outcome "execution_monitoring", %{
              phase: get_data(:phase),
              performance_data: get_data(:execution_metrics),
              analysis_results: get_data(:execution_analysis),
              predictions: get_data(:outcome_predictions),
              context: get_data(:execution_context)
            }
          end

        _ ->
          sequence do
            log(:debug, "👁️  [MONITOR] Processing general system event: #{get_data(:event_type)}")

            # General event processing with pattern recognition
            call_llm(
              provider: :openai,
              model: "gpt-4",
              role: "System pattern analyst",
              prompt: "Analyze system event for patterns and insights: #{inspect(get_data(:event_data))}"
            )

            put_data :pattern_analysis, get_result()
          end
      end
    end
  end

  # Advanced coordination oversight with AI-powered consensus building
  behavior :intelligent_coordination_oversight, triggers_on: [:agent_coordination_started, :consensus_building, :coordination_conflict] do
    sequence do
      log(:info, "👁️  [MONITOR] Providing AI-powered coordination oversight")

      reason "How can I optimize this agent coordination for best outcomes?" do
        [
          %{
            id: :coordination_analysis,
            question: "What is the current state and effectiveness of agent coordination?",
            analysis_type: :assessment,
            context_required: [:coordination_data, :agent_statuses, :communication_patterns],
            output_format: :analysis
          },
          %{
            id: :bottleneck_identification,
            question: "Are there any bottlenecks or inefficiencies in the coordination?",
            analysis_type: :evaluation,
            context_required: [:coordination_flow, :response_times, :decision_delays],
            output_format: :analysis
          },
          %{
            id: :optimization_opportunities,
            question: "What opportunities exist to improve coordination effectiveness?",
            analysis_type: :synthesis,
            context_required: [:coordination_analysis, :bottleneck_results, :optimization_strategies],
            output_format: :recommendation
          }
        ]
      end

      # Coordinate coordination optimization (meta-coordination)
      coordinate [
        %{
          id: :coordination_optimizer,
          role: "Multi-agent coordination specialist",
          model: "gpt-4",
          capabilities: [:coordination_analysis, :consensus_building, :conflict_resolution],
          reasoning_style: :synthetic
        }
      ], type: :consensus, consensus_threshold: 0.9

      # Apply coordination improvements
      case get_data(:coordination_status) do
        :consensus_achieved ->
          sequence do
            log(:info, "👁️  [MONITOR] 🎉 Consensus achieved - excellent coordination!")

            # Analyze what made coordination successful
            learn_from_outcome "coordination_success", %{
              coordination_type: get_data(:coordination_type),
              participants: get_data(:participating_agents),
              success_factors: get_data(:success_analysis),
              duration: get_data(:coordination_duration),
              context: get_data(:coordination_context)
            }

            broadcast_reasoning "Successful coordination pattern identified", get_connected_agents()
          end

        :consensus_building ->
          sequence do
            log(:info, "👁️  [MONITOR] Facilitating consensus building process")

            # Provide coordination facilitation
            call_llm(
              provider: :anthropic,
              model: "claude-3",
              role: "Consensus facilitation specialist",
              prompt: "Facilitate consensus among agents: #{inspect(get_data(:coordination_state))}",
              temperature: 0.4
            )

            put_data :facilitation_strategy, get_result()

            # Implement facilitation recommendations
            emit_event :coordination_facilitation, %{
              strategy: get_data(:facilitation_strategy),
              recommendations: get_data(:facilitation_actions),
              expected_outcome: get_data(:consensus_prediction)
            }
          end

        :coordination_conflict ->
          sequence do
            log(:warning, "👁️  [MONITOR] ⚠️ Coordination conflict detected - initiating resolution")

            # Analyze conflict and provide resolution strategies
            reason "How can I resolve this coordination conflict effectively?" do
              [
                %{
                  id: :conflict_analysis,
                  question: "What is the root cause of this coordination conflict?",
                  analysis_type: :assessment,
                  context_required: [:conflict_data, :agent_positions, :disagreement_points],
                  output_format: :analysis
                },
                %{
                  id: :resolution_strategies,
                  question: "What strategies could resolve this conflict?",
                  analysis_type: :synthesis,
                  context_required: [:conflict_analysis, :resolution_options, :stakeholder_interests],
                  output_format: :recommendation
                }
              ]
            end

            # Implement conflict resolution
            coordinate [
              %{
                id: :conflict_mediator,
                role: "Conflict resolution specialist",
                model: "gpt-4",
                capabilities: [:mediation, :conflict_analysis, :compromise_facilitation],
                reasoning_style: :synthetic
              }
            ]

            emit_event :conflict_resolution_initiated, %{
              conflict_analysis: get_data(:conflict_analysis),
              resolution_strategy: get_data(:selected_resolution),
              mediation_plan: get_data(:mediation_strategy)
            }
          end
      end
    end
  end

  # Comprehensive system health and performance analysis
  behavior :system_health_analysis, triggers_on: [:performance_anomaly, :system_degradation, :health_check] do
    sequence do
      log(:info, "👁️  [MONITOR] Conducting comprehensive system health analysis")

      # Multi-dimensional system health assessment
      parallel do
        # Performance analysis
        call_llm(
          provider: :openai,
          model: "gpt-4",
          role: "System performance analyst",
          system: """
          You analyze system performance metrics to identify trends, anomalies,
          and optimization opportunities. Focus on actionable insights.
          """,
          prompt: build_performance_analysis_prompt(),
          temperature: 0.2
        )

        # Health trend analysis
        call_llm(
          provider: :google,
          model: "gemini-pro",
          role: "System health trend specialist",
          prompt: "Analyze system health trends: #{inspect(get_data(:health_metrics))}",
          temperature: 0.3
        )

        # Predictive health modeling
        call_llm(
          provider: :anthropic,
          model: "claude-3",
          role: "Predictive health analyst",
          prompt: "Predict system health trajectory: #{inspect(get_data(:trend_data))}",
          temperature: 0.25
        )
      end

      # Synthesize comprehensive health assessment
      reason "What is the overall system health and what actions are needed?" do
        [
          %{
            id: :health_synthesis,
            question: "What is the comprehensive health status of the system?",
            analysis_type: :synthesis,
            context_required: [:performance_analysis, :health_trends, :predictive_models],
            output_format: :analysis
          },
          %{
            id: :risk_assessment,
            question: "What are the current and emerging health risks?",
            analysis_type: :assessment,
            context_required: [:health_analysis, :trend_projections, :historical_patterns],
            output_format: :analysis
          },
          %{
            id: :action_recommendations,
            question: "What specific actions should be taken to maintain/improve system health?",
            analysis_type: :synthesis,
            context_required: [:health_synthesis, :risk_assessment, :intervention_options],
            output_format: :recommendation
          }
        ]
      end

      # Generate health recommendations and alerts
      case get_data(:overall_health_score) do
        score when score >= 0.9 ->
          log(:info, "👁️  [MONITOR] ✅ System health excellent (#{Float.round(score * 100, 1)}%)")

        score when score >= 0.7 ->
          log(:info, "👁️  [MONITOR] ✅ System health good (#{Float.round(score * 100, 1)}%) - monitoring")

        score when score >= 0.5 ->
          sequence do
            log(:warning, "👁️  [MONITOR] ⚠️ System health degraded (#{Float.round(score * 100, 1)}%) - intervention recommended")

            emit_event :health_intervention_recommended, %{
              health_score: score,
              critical_issues: get_data(:critical_health_issues),
              recommendations: get_data(:health_recommendations),
              urgency: :medium
            }
          end

        score ->
          sequence do
            log(:error, "👁️  [MONITOR] 🚨 System health critical (#{Float.round(score * 100, 1)}%) - immediate action required")

            emit_event :health_critical_alert, %{
              health_score: score,
              critical_failures: get_data(:critical_failures),
              emergency_actions: get_data(:emergency_recommendations),
              urgency: :critical
            }

            escalate_to_human(
              priority: :critical,
              reason: "System health critically degraded",
              data: get_data(:health_crisis_data)
            )
          end
      end

      # Store health analysis for trend learning
      learn_from_outcome "system_health_monitoring", %{
        health_score: get_data(:overall_health_score),
        analysis_results: get_data(:health_analysis),
        predictions: get_data(:health_predictions),
        actions_taken: get_data(:recommended_actions),
        context: get_data(:monitoring_context)
      }
    end
  end

  # Helper functions for monitoring
  defp build_execution_monitoring_prompt do
    """
    Analyze current deployment execution status:

    Execution Phase: #{get_data(:phase)}
    Progress: #{get_data(:progress, "unknown")}%
    Performance Metrics: #{inspect(get_data(:execution_metrics))}
    Historical Baseline: #{inspect(get_data(:baseline_metrics))}

    Provide analysis of:
    1. Current execution health and trajectory
    2. Performance compared to baseline and expectations
    3. Any concerning patterns or anomalies
    4. Predicted completion status and timeline
    5. Recommendations for optimization or intervention

    Focus on actionable insights and early warning indicators.
    """
  end

  defp build_performance_analysis_prompt do
    """
    Conduct comprehensive system performance analysis:

    Current Metrics: #{inspect(get_data(:current_metrics))}
    Historical Trends: #{inspect(get_data(:performance_trends))}
    Baseline Performance: #{inspect(get_data(:performance_baseline))}
    System Load: #{get_data(:system_load, "unknown")}

    Analyze:
    1. Performance trends and trajectory
    2. Deviation from baseline and normal ranges
    3. Performance bottlenecks and constraints
    4. Resource utilization efficiency
    5. Optimization opportunities
    6. Early warning indicators for performance degradation

    Provide specific, actionable recommendations for performance improvement.
    """
  end

  defp get_connected_agents do
    # Return list of connected agents for broadcasting
    [:deployment_planner, :security_agent, :executor_agent]
  end
end
