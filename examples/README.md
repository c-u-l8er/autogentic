# 📚 Autogentic v2.0 Examples

This directory contains comprehensive examples demonstrating the power and flexibility of Autogentic v2.0. Each example is designed to showcase specific features and can be run independently.

## 🗂️ Directory Structure

```
examples/
├── basic/              # Fundamental concepts and simple agents
├── coordination/       # Multi-agent coordination scenarios
├── reasoning/          # Advanced reasoning and decision-making
└── real_world/         # Production-ready use cases
```

## 🟢 Basic Examples

Perfect for getting started with Autogentic concepts.

### [hello_agent.exs](basic/hello_agent.exs)
**Your first Autogentic agent**
- Basic agent creation and lifecycle
- State transitions with effects
- Event handling and context management
- Simple behavior definitions

```bash
elixir examples/basic/hello_agent.exs
```

### [effects_showcase.exs](basic/effects_showcase.exs)
**Comprehensive effects demonstration**
- Basic effects (logging, data storage, events)
- Sequence execution patterns
- Parallel effect processing
- Error handling and compensation
- Performance comparisons

```bash
elixir examples/basic/effects_showcase.exs
```

### [learning_agent.exs](basic/learning_agent.exs)
**Adaptive behavior and continuous learning**
- Learning from successful and failed outcomes
- Behavioral adaptation over time
- Reasoning-driven learning optimization
- Cross-agent knowledge sharing

```bash
elixir examples/basic/learning_agent.exs
```

## 🤝 Multi-Agent Coordination

Examples showing how agents work together to solve complex problems.

### [deployment_team.exs](coordination/deployment_team.exs)
**Coordinated software deployment workflow**
- Four specialized agents (Coordinator, Dev, QA, Ops)
- Real-time inter-agent communication
- Complex workflow orchestration
- Status synchronization across agents

**Agents:**
- **Deployment Coordinator**: Orchestrates the entire deployment process
- **Dev Agent**: Handles code validation and building
- **QA Agent**: Runs comprehensive testing
- **Ops Agent**: Manages infrastructure and deployment

```bash
elixir examples/coordination/deployment_team.exs
```

## 🧠 Advanced Reasoning

Sophisticated reasoning and decision-making scenarios.

### [decision_maker.exs](reasoning/decision_maker.exs)
**Multi-step reasoning and analysis**
- Basic reasoning session management
- Multi-step analysis workflows
- Decision-making with confidence scoring
- Knowledge base querying
- Context-aware reasoning

**Features:**
- Assessment, evaluation, and synthesis reasoning types
- Confidence scoring for each reasoning step
- Knowledge base integration
- Agent-driven decision processes

```bash
elixir examples/reasoning/decision_maker.exs
```

## 🏭 Real-World Applications

Production-ready examples showing practical Autogentic applications.

### [data_pipeline.exs](real_world/data_pipeline.exs)
**Enterprise data processing pipeline**
- Four-agent data processing architecture
- Quality monitoring and anomaly detection
- ML model training and prediction
- Intelligent pipeline optimization

**Pipeline Agents:**
- **Data Ingestion Agent**: Collects and validates data from sources
- **Data Processor Agent**: Transforms and enriches data
- **ML Analyzer Agent**: Trains models and generates predictions
- **Quality Monitor Agent**: Ensures data quality and detects anomalies

**Features:**
- End-to-end data pipeline orchestration
- Quality assurance and monitoring
- Machine learning integration
- Reasoning-driven pipeline optimization
- Real-time metrics and reporting

```bash
elixir examples/real_world/data_pipeline.exs
```

## 🚀 Running Examples

### Recommended: Use the Example Runner
```bash
# The example runner ensures Autogentic system is properly initialized
mix run run_example.exs examples/basic/hello_agent.exs
mix run run_example.exs examples/coordination/deployment_team.exs
mix run run_example.exs examples/reasoning/decision_maker.exs
mix run run_example.exs examples/real_world/data_pipeline.exs

# List all available examples
mix run run_example.exs
```

### Interactive Mode
```bash
# Start IEx with full Autogentic system
iex -S mix

# Then load and run examples:
iex> c "examples/basic/hello_agent.exs"
iex> HelloAgentExample.run()
```

### Direct Execution (Advanced)
```bash
# Note: Requires manual system initialization
# Use example runner instead for better experience
cd examples && elixir run_example.exs basic/hello_agent.exs
```

## 📖 Learning Path

We recommend following this learning path through the examples:

1. **Start with [hello_agent.exs](basic/hello_agent.exs)** - Learn basic agent concepts
2. **Explore [effects_showcase.exs](basic/effects_showcase.exs)** - Understand the effects system
3. **Study [decision_maker.exs](reasoning/decision_maker.exs)** - Learn reasoning capabilities
4. **Try [deployment_team.exs](coordination/deployment_team.exs)** - See multi-agent coordination
5. **Examine [learning_agent.exs](basic/learning_agent.exs)** - Understand adaptive behavior
6. **Build with [data_pipeline.exs](real_world/data_pipeline.exs)** - Apply to real-world scenarios

## 🔧 Prerequisites

To run these examples, you need:

- Elixir 1.15+
- Erlang/OTP 24+
- Autogentic v2.0 dependencies (run `mix deps.get`)

## 💡 Key Concepts Demonstrated

### Effects System
- **Sequence Effects**: Execute effects one after another
- **Parallel Effects**: Execute multiple effects simultaneously  
- **Error Handling**: Retry, compensation, and circuit breaker patterns
- **Context Management**: Sophisticated state handling across effect chains

### Agent Coordination
- **Message Passing**: Agents communicate through structured messages
- **Reasoning Broadcasts**: Share insights and analysis between agents
- **Event Systems**: Emit and handle system-wide events
- **State Synchronization**: Coordinate state changes across multiple agents

### Reasoning Engine
- **Multi-Step Analysis**: Break complex decisions into reasoning steps
- **Confidence Scoring**: Each step includes confidence metrics
- **Knowledge Integration**: Query accumulated knowledge for better decisions
- **Pattern Recognition**: Learn and reuse successful reasoning approaches

### Learning & Adaptation
- **Outcome Learning**: Learn from successful and failed experiences
- **Behavioral Adaptation**: Modify behavior based on performance
- **Cross-Agent Sharing**: Share learned patterns between agents
- **Continuous Improvement**: Self-optimizing system performance

## 🐛 Troubleshooting

### Common Issues

**Agent won't start:**
```bash
# Make sure you have started the Autogentic application
iex -S mix
```

**Effects not executing:**
```bash
# Check that the effects engine is running
Autogentic.Effects.Engine.start_link([])
```

**Reasoning sessions failing:**
```bash
# Ensure the reasoning engine is available
Autogentic.Reasoning.Engine.start_link([])
```

### Getting Help

- Check the main [README.md](../README.md) for general setup
- Review individual example source code for detailed comments
- Join our [Discord community](https://discord.gg/autogentic) for help
- Open an [issue](https://github.com/your-org/autogentic/issues) if you find bugs

## 🎯 Next Steps

After exploring these examples, you might want to:

1. **Create your own agent** using the patterns you've learned
2. **Combine multiple examples** to build more complex scenarios
3. **Extend existing examples** with additional features
4. **Contribute new examples** to help the community

Happy coding with Autogentic v2.0! 🚀
