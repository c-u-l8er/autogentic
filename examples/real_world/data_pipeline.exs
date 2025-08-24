#!/usr/bin/env elixir

# Data Pipeline - Real-World Example
# This example shows how Autogentic can orchestrate a complex data processing pipeline
# with multiple agents handling different stages of data transformation and analysis

defmodule DataIngestionAgent do
  use Autogentic.Agent, name: :data_ingestion
  require Logger

  agent :data_ingestion do
    capability [:data_collection, :data_validation, :stream_processing]
    reasoning_style :systematic
    connects_to [:data_processor, :quality_monitor]
    initial_state :monitoring
  end

  state :monitoring do
    # Monitoring data sources for new data
  end

  state :ingesting do
    # Actively ingesting data from sources
  end

  state :validating do
    # Validating ingested data
  end

  transition from: :monitoring, to: :ingesting, when_receives: :new_data_available do
    sequence do
      log(:info, "📥 Starting data ingestion")
      put_data(:ingestion_started, DateTime.utc_now())
      put_data(:source_count, 0)
      put_data(:records_ingested, 0)
    end
  end

  transition from: :ingesting, to: :validating, when_receives: :ingestion_complete do
    sequence do
      log(:info, "✅ Ingestion complete, starting validation")
      put_data(:validation_started, DateTime.utc_now())
      broadcast_reasoning("Data ingestion completed", [:data_processor])
    end
  end

  transition from: :validating, to: :monitoring, when_receives: :validation_complete do
    sequence do
      log(:info, "🔍 Validation complete, returning to monitoring")
      put_data(:last_successful_ingestion, DateTime.utc_now())
      emit_event(:data_ready_for_processing, %{records: get_record_count()})
    end
  end

  defp get_record_count do
    # Simulate record count
    :rand.uniform(1000) + 500
  end

  # Handle get_state calls from Autogentic.get_agent_state/1
  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state_and_data, {:reply, from, {:ok, {state, data}}}}
  end
end

defmodule DataProcessorAgent do
  use Autogentic.Agent, name: :data_processor
  require Logger

  agent :data_processor do
    capability [:data_transformation, :feature_engineering, :batch_processing]
    reasoning_style :analytical
    connects_to [:data_ingestion, :ml_analyzer, :quality_monitor]
    initial_state :idle
  end

  state :idle do
    # Waiting for data to process
  end

  state :transforming do
    # Applying data transformations
  end

  state :enriching do
    # Enriching data with additional features
  end

  transition from: :idle, to: :transforming, when_receives: :process_data do
    sequence do
      log(:info, "⚙️ Starting data transformation")
      put_data(:processing_started, DateTime.utc_now())
      put_data(:transformation_type, :standard)
    end
  end

  transition from: :transforming, to: :enriching, when_receives: :transformation_complete do
    sequence do
      log(:info, "🔄 Transformation complete, starting enrichment")
      put_data(:enrichment_started, DateTime.utc_now())
      put_data(:features_added, 0)
    end
  end

  transition from: :enriching, to: :idle, when_receives: :processing_complete do
    sequence do
      log(:info, "✨ Processing complete, data ready for analysis")
      put_data(:processing_completed, DateTime.utc_now())
      broadcast_reasoning("Data processing completed", [:ml_analyzer])
      emit_event(:processed_data_available, %{
        records_processed: get_processed_count(),
        quality_score: calculate_quality_score()
      })
    end
  end

  defp get_processed_count do
    :rand.uniform(800) + 400
  end

  defp calculate_quality_score do
    :rand.uniform() * 0.3 + 0.7  # Score between 0.7 and 1.0
  end

  # Handle get_state calls from Autogentic.get_agent_state/1
  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state_and_data, {:reply, from, {:ok, {state, data}}}}
  end
end

defmodule MLAnalyzerAgent do
  use Autogentic.Agent, name: :ml_analyzer
  require Logger

  agent :ml_analyzer do
    capability [:machine_learning, :pattern_recognition, :predictive_analysis]
    reasoning_style :creative
    connects_to [:data_processor, :insight_generator]
    initial_state :standby
  end

  state :standby do
    # Ready to run analysis
  end

  state :training do
    # Training ML models
  end

  state :predicting do
    # Generating predictions
  end

  transition from: :standby, to: :training, when_receives: :train_model do
    sequence do
      log(:info, "🤖 Starting ML model training")
      put_data(:training_started, DateTime.utc_now())
      put_data(:model_type, :ensemble)
      put_data(:training_samples, get_training_sample_count())
    end
  end

  transition from: :training, to: :predicting, when_receives: :training_complete do
    sequence do
      log(:info, "🎯 Training complete, generating predictions")
      put_data(:prediction_started, DateTime.utc_now())
      put_data(:model_accuracy, calculate_model_accuracy())
    end
  end

  transition from: :predicting, to: :standby, when_receives: :analysis_complete do
    sequence do
      log(:info, "📊 Analysis complete, insights generated")
      put_data(:analysis_completed, DateTime.utc_now())
      broadcast_reasoning("ML analysis completed", [:insight_generator])
      emit_event(:insights_available, %{
        predictions_generated: get_prediction_count(),
        confidence: get_confidence_score()
      })
    end
  end

  defp get_training_sample_count do
    :rand.uniform(5000) + 1000
  end

  defp calculate_model_accuracy do
    :rand.uniform() * 0.15 + 0.85  # Accuracy between 85% and 100%
  end

  defp get_prediction_count do
    :rand.uniform(200) + 100
  end

  defp get_confidence_score do
    :rand.uniform() * 0.2 + 0.8  # Confidence between 80% and 100%
  end

  # Handle get_state calls from Autogentic.get_agent_state/1
  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state_and_data, {:reply, from, {:ok, {state, data}}}}
  end
end

defmodule QualityMonitorAgent do
  use Autogentic.Agent, name: :quality_monitor
  require Logger

  agent :quality_monitor do
    capability [:quality_assurance, :anomaly_detection, :monitoring]
    reasoning_style :critical
    connects_to [:data_ingestion, :data_processor]
    initial_state :monitoring
  end

  state :monitoring do
    # Continuously monitoring data quality
  end

  state :investigating do
    # Investigating quality issues
  end

  behavior :quality_check, triggers_on: [:data_quality_check] do
    sequence do
      log(:debug, "🔍 Performing quality check")
      put_data(:last_quality_check, DateTime.utc_now())
      put_data(:quality_issues_found, detect_quality_issues())
    end
  end

  behavior :anomaly_detected, triggers_on: [:anomaly_alert] do
    sequence do
      log(:warn, "⚠️ Anomaly detected in data pipeline")
      put_data(:anomaly_detected_at, DateTime.utc_now())
      broadcast_reasoning("Quality anomaly detected", [:data_ingestion, :data_processor])
    end
  end

  transition from: :monitoring, to: :investigating, when_receives: :investigate_issue do
    sequence do
      log(:info, "🕵️ Starting quality investigation")
      put_data(:investigation_started, DateTime.utc_now())
    end
  end

  defp detect_quality_issues do
    # Simulate quality issue detection
    if :rand.uniform() < 0.1 do
      ["missing_values", "data_drift"]
    else
      []
    end
  end

  # Handle get_state calls from Autogentic.get_agent_state/1
  def handle_event({:call, from}, :get_state, state, data) do
    {:keep_state_and_data, {:reply, from, {:ok, {state, data}}}}
  end
end

# Main pipeline orchestrator
defmodule DataPipelineOrchestrator do
  def run do
    IO.puts("🏭 Data Pipeline Orchestration Example")
    IO.puts(String.duplicate("=", 50))

    # Start all pipeline agents
    agents = start_pipeline_agents()

    # Run the complete pipeline
    run_pipeline_cycle(agents)

    # Show pipeline metrics
    show_pipeline_metrics(agents)

    # Cleanup
    cleanup_agents(agents)

    IO.puts("\n✨ Data pipeline example completed!")
  end

  defp start_pipeline_agents do
    IO.puts("\n🚀 Starting data pipeline agents...")

    {:ok, ingestion} = DataIngestionAgent.start_link()
    {:ok, processor} = DataProcessorAgent.start_link()
    {:ok, ml_analyzer} = MLAnalyzerAgent.start_link()
    {:ok, quality_monitor} = QualityMonitorAgent.start_link()

    agents = %{
      ingestion: ingestion,
      processor: processor,
      ml_analyzer: ml_analyzer,
      quality_monitor: quality_monitor
    }

    IO.puts("✅ All pipeline agents started")
    agents
  end

  defp run_pipeline_cycle(agents) do
    IO.puts("\n🔄 Running complete pipeline cycle...")

    # Stage 1: Data Ingestion
    IO.puts("\n1️⃣ Data Ingestion Phase")
    GenStateMachine.cast(agents.ingestion, :new_data_available)
    Process.sleep(200)

    GenStateMachine.cast(agents.ingestion, :ingestion_complete)
    Process.sleep(150)

    GenStateMachine.cast(agents.quality_monitor, :data_quality_check)
    Process.sleep(100)

    GenStateMachine.cast(agents.ingestion, :validation_complete)
    Process.sleep(100)

    # Stage 2: Data Processing
    IO.puts("\n2️⃣ Data Processing Phase")
    GenStateMachine.cast(agents.processor, :process_data)
    Process.sleep(300)

    GenStateMachine.cast(agents.processor, :transformation_complete)
    Process.sleep(200)

    GenStateMachine.cast(agents.processor, :processing_complete)
    Process.sleep(150)

    # Stage 3: ML Analysis
    IO.puts("\n3️⃣ Machine Learning Analysis Phase")
    GenStateMachine.cast(agents.ml_analyzer, :train_model)
    Process.sleep(400)

    GenStateMachine.cast(agents.ml_analyzer, :training_complete)
    Process.sleep(250)

    GenStateMachine.cast(agents.ml_analyzer, :analysis_complete)
    Process.sleep(100)

    IO.puts("\n🎯 Pipeline cycle completed successfully!")
  end

  defp show_pipeline_metrics(agents) do
    IO.puts("\n📊 Pipeline Metrics & Agent States:")
    IO.puts(String.duplicate("=", 40))

    Enum.each(agents, fn {name, pid} ->
      {state, data} = Autogentic.get_agent_state(pid)
      IO.puts("\n#{format_agent_name(name)}:")
      IO.puts("  State: #{state}")

      if map_size(data.context) > 0 do
        context_summary = summarize_context(data.context)
        IO.puts("  Key Metrics: #{context_summary}")
      end
    end)
  end

  defp format_agent_name(name) do
    name
    |> to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp summarize_context(context) do
    # Extract key metrics from context
    metrics = []

    metrics = if context[:records_ingested], do: ["#{context[:records_ingested]} records" | metrics], else: metrics
    metrics = if context[:model_accuracy], do: ["#{Float.round(context[:model_accuracy] * 100, 1)}% accuracy" | metrics], else: metrics
    metrics = if context[:quality_issues_found], do: ["#{length(context[:quality_issues_found])} quality issues" | metrics], else: metrics

    if length(metrics) > 0 do
      Enum.join(metrics, ", ")
    else
      "No metrics available"
    end
  end

  defp cleanup_agents(agents) do
    IO.puts("\n🧹 Cleaning up pipeline agents...")
    Enum.each(agents, fn {_name, pid} ->
      GenStateMachine.stop(pid)
    end)
  end
end

# Advanced pipeline with reasoning
defmodule IntelligentPipelineDemo do
  def run do
    IO.puts("\n🧠 Intelligent Pipeline with Reasoning")
    IO.puts(String.duplicate("=", 45))

    # Demonstrate reasoning-driven pipeline optimization
    context = %{
      data_volume: :high,
      processing_urgency: :normal,
      quality_threshold: 0.95,
      available_resources: :moderate
    }

    IO.puts("\n🤔 Reasoning about pipeline optimization...")
    {:ok, session_id} = Autogentic.start_reasoning("pipeline_optimization", context)

    # Step 1: Assess current pipeline performance
    step1 = %{
      id: :performance_assessment,
      question: "How is the current pipeline performing?",
      analysis_type: :assessment,
      context_required: [:data_volume, :available_resources]
    }

    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step1)

    # Step 2: Evaluate optimization needs
    step2 = %{
      id: :optimization_evaluation,
      question: "What optimizations are needed?",
      analysis_type: :evaluation,
      context_required: [:processing_urgency, :quality_threshold]
    }

    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step2)

    # Step 3: Generate optimization recommendations
    step3 = %{
      id: :optimization_synthesis,
      question: "What's the best optimization strategy?",
      analysis_type: :synthesis,
      context_required: [:data_volume, :processing_urgency, :available_resources, :quality_threshold]
    }

    {:ok, _} = Autogentic.Reasoning.Engine.add_reasoning_step(session_id, step3)

    # Get conclusion
    {:ok, conclusion} = Autogentic.Reasoning.Engine.conclude_reasoning_session(session_id)

    IO.puts("\n📋 Pipeline Optimization Results:")
    IO.puts("Confidence: #{conclusion.confidence}")
    IO.puts("Recommendation: #{conclusion.recommendation}")
    IO.puts("Quality Assessment: #{conclusion.reasoning_quality}")
  end
end

# Main runner
defmodule DataPipelineExample do
  def run do
    DataPipelineOrchestrator.run()
    IntelligentPipelineDemo.run()
  end
end

# Auto-run the example
DataPipelineExample.run()
