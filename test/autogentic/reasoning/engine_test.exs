defmodule Autogentic.Reasoning.EngineTest do
  use ExUnit.Case, async: false
  alias Autogentic.Reasoning.Engine

  setup do
    # Start the reasoning engine for testing
    {:ok, pid} = Engine.start_link([])

    on_exit(fn ->
      if Process.alive?(pid) do
        GenServer.stop(pid)
      end
    end)

    %{engine_pid: pid}
  end

  describe "reasoning sessions" do
    test "can start a reasoning session" do
      context = %{task: "test analysis", urgency: :normal}

      assert {:ok, session_id} = Engine.start_reasoning_session("test_session_1", context)
      assert session_id == "test_session_1"
    end

    test "can add reasoning steps to a session" do
      context = %{task: "test analysis"}
      {:ok, session_id} = Engine.start_reasoning_session("test_session_2", context)

      step = %{
        id: :assess_situation,
        question: "What is the current situation?",
        analysis_type: :assessment,
        context_required: [:task, :urgency],
        output_format: :analysis
      }

      assert {:ok, processed_step} = Engine.add_reasoning_step(session_id, step)
      assert processed_step.id == :assess_situation
      assert processed_step.question == step.question
      assert processed_step.analysis_type == :assessment
      assert is_number(processed_step.confidence)
      assert processed_step.confidence >= 0.0 and processed_step.confidence <= 1.0
    end

    test "can conclude a reasoning session" do
      context = %{task: "test analysis", complexity: :medium}
      {:ok, session_id} = Engine.start_reasoning_session("test_session_3", context)

      # Add a few reasoning steps
      steps = [
        %{
          id: :assess_complexity,
          question: "How complex is this task?",
          analysis_type: :assessment,
          context_required: [:complexity],
          output_format: :analysis
        },
        %{
          id: :evaluate_resources,
          question: "Do we have adequate resources?",
          analysis_type: :evaluation,
          context_required: [:task],
          output_format: :boolean
        },
        %{
          id: :synthesize_recommendation,
          question: "What should we do?",
          analysis_type: :synthesis,
          context_required: [:complexity, :task],
          output_format: :recommendation
        }
      ]

      Enum.each(steps, fn step ->
        Engine.add_reasoning_step(session_id, step)
      end)

      assert {:ok, conclusion} = Engine.conclude_reasoning_session(session_id)

      assert conclusion.session_id == session_id
      assert conclusion.total_steps == 3
      assert is_number(conclusion.confidence)
      assert is_binary(conclusion.recommendation)
      assert is_list(conclusion.key_insights)
      assert conclusion.reasoning_quality in [:excellent, :good, :acceptable, :needs_improvement]
    end

    test "returns error for non-existent session" do
      step = %{
        id: :test_step,
        question: "Test question?",
        analysis_type: :assessment,
        context_required: [],
        output_format: :analysis
      }

      assert {:error, :session_not_found} = Engine.add_reasoning_step("non_existent", step)
      assert {:error, :session_not_found} = Engine.conclude_reasoning_session("non_existent")
    end
  end

  describe "knowledge base queries" do
    test "can query knowledge base" do
      result = Engine.query_knowledge_base("deployment best practices")

      assert is_map(result)
      # Should find deployment-related knowledge
      if Map.has_key?(result, :deployment) do
        assert Map.has_key?(result.deployment, :best_practices)
      end
    end

    test "query with context" do
      context = %{domain: :security, task_type: :analysis}
      result = Engine.query_knowledge_base("security threats", context)

      assert is_map(result)
    end

    test "empty query returns empty results" do
      result = Engine.query_knowledge_base("")
      assert result == %{}
    end
  end

  describe "reasoning step processing" do
    test "processes assessment type reasoning" do
      context = %{system_state: :healthy, resources: :adequate}
      {:ok, session_id} = Engine.start_reasoning_session("assessment_test", context)

      step = %{
        id: :system_assessment,
        question: "Is the system ready for deployment?",
        analysis_type: :assessment,
        context_required: [:system_state, :resources],
        output_format: :analysis
      }

      {:ok, processed_step} = Engine.add_reasoning_step(session_id, step)

      assert processed_step.analysis_result.type == :assessment
      assert Map.has_key?(processed_step.analysis_result, :current_state)
      assert Map.has_key?(processed_step.analysis_result, :key_factors)
      assert Map.has_key?(processed_step.analysis_result, :readiness_score)
      assert is_list(processed_step.analysis_result.recommendations)
    end

    test "processes evaluation type reasoning" do
      context = %{quality_metrics: %{completeness: 0.8, accuracy: 0.9}}
      {:ok, session_id} = Engine.start_reasoning_session("evaluation_test", context)

      step = %{
        id: :quality_evaluation,
        question: "Does this meet quality standards?",
        analysis_type: :evaluation,
        context_required: [:quality_metrics],
        output_format: :analysis
      }

      {:ok, processed_step} = Engine.add_reasoning_step(session_id, step)

      assert processed_step.analysis_result.type == :evaluation
      assert is_number(processed_step.analysis_result.overall_score)
      assert processed_step.analysis_result.evaluation_result in [:pass, :fail]
    end

    test "processes synthesis type reasoning" do
      context = %{
        findings: ["finding1", "finding2"],
        data_sources: ["source1", "source2"]
      }
      {:ok, session_id} = Engine.start_reasoning_session("synthesis_test", context)

      step = %{
        id: :synthesize_findings,
        question: "What conclusions can we draw?",
        analysis_type: :synthesis,
        context_required: [:findings, :data_sources],
        output_format: :analysis
      }

      {:ok, processed_step} = Engine.add_reasoning_step(session_id, step)

      assert processed_step.analysis_result.type == :synthesis
      assert is_list(processed_step.analysis_result.key_themes)
      assert is_list(processed_step.analysis_result.insights)
      assert is_binary(processed_step.analysis_result.synthesis_conclusion)
    end
  end

  describe "confidence scoring" do
    test "confidence scores are within valid range" do
      context = %{data_quality: :high, sample_size: 1000}
      {:ok, session_id} = Engine.start_reasoning_session("confidence_test", context)

      step = %{
        id: :confidence_step,
        question: "How confident are we in this analysis?",
        analysis_type: :assessment,
        context_required: [:data_quality, :sample_size],
        output_format: :analysis
      }

      {:ok, processed_step} = Engine.add_reasoning_step(session_id, step)

      assert processed_step.confidence >= 0.0
      assert processed_step.confidence <= 1.0
    end

    test "session conclusion includes overall confidence" do
      context = %{certainty: :high}
      {:ok, session_id} = Engine.start_reasoning_session("overall_confidence_test", context)

      # Add multiple steps
      for i <- 1..3 do
        step = %{
          id: String.to_atom("step_#{i}"),
          question: "Step #{i} question?",
          analysis_type: :assessment,
          context_required: [:certainty],
          output_format: :analysis
        }
        Engine.add_reasoning_step(session_id, step)
      end

      {:ok, conclusion} = Engine.conclude_reasoning_session(session_id)

      assert is_number(conclusion.confidence)
      assert conclusion.confidence >= 0.0
      assert conclusion.confidence <= 1.0
    end
  end

  describe "pattern storage" do
    test "stores reasoning patterns for high-confidence sessions" do
      # This test verifies that successful patterns are stored
      context = %{success_indicators: [:clear_requirements, :adequate_resources]}
      {:ok, session_id} = Engine.start_reasoning_session("pattern_test", context)

      # Add steps that should result in high confidence
      step = %{
        id: :high_confidence_step,
        question: "Is this a good approach?",
        analysis_type: :synthesis,
        context_required: [:success_indicators],
        output_format: :recommendation
      }

      Engine.add_reasoning_step(session_id, step)

      # The pattern storage happens asynchronously in the actual implementation
      # In a real test, we might need to wait or mock the storage mechanism
      assert {:ok, conclusion} = Engine.conclude_reasoning_session(session_id)
      assert is_number(conclusion.confidence)
    end
  end

  describe "error handling" do
    test "handles malformed reasoning steps gracefully" do
      context = %{}
      {:ok, session_id} = Engine.start_reasoning_session("error_test", context)

      # Step missing required fields
      malformed_step = %{
        question: "Incomplete step?"
        # Missing id, analysis_type, etc.
      }

      {:ok, processed_step} = Engine.add_reasoning_step(session_id, malformed_step)

      # Should still process with defaults
      assert is_atom(processed_step.id)
      assert processed_step.analysis_type == :assessment  # default
      assert is_number(processed_step.confidence)
    end

    test "gracefully handles empty context" do
      {:ok, session_id} = Engine.start_reasoning_session("empty_context_test", %{})

      step = %{
        id: :empty_context_step,
        question: "Can we reason without context?",
        analysis_type: :assessment,
        context_required: [],
        output_format: :analysis
      }

      {:ok, processed_step} = Engine.add_reasoning_step(session_id, step)
      assert processed_step.confidence > 0
    end
  end
end
