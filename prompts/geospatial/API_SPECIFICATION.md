# 🌐 Intelligent Geospatial Platform API Specification

**Drop-in replacement for Tile38 and HiveKit with AI enhancements**

## 🎯 API Philosophy

Our API maintains **backward compatibility** with existing geospatial platforms while adding revolutionary **AI-powered enhancements**:

- **Tile38 Compatible**: All Redis protocol commands supported
- **HiveKit Compatible**: REST API with enhanced intelligence
- **AI Enhanced**: Every operation can be AI-optimized
- **Real-time**: WebSocket streams for live data
- **Intelligent**: Built-in reasoning and prediction

## 🔄 Migration Compatibility

### From Tile38 (Redis Protocol)
```redis
# Existing Tile38 commands work unchanged
SET fleet truck1 POINT 37.7749 -122.4194
GET fleet truck1
NEARBY fleet POINT 37.7749 -122.4194 1000

# Enhanced with AI (optional parameters)
SET fleet truck1 POINT 37.7749 -122.4194 AI_OPTIMIZE true
NEARBY fleet POINT 37.7749 -122.4194 1000 AI_PREDICT true
```

### From HiveKit (REST API)
```javascript
// Existing HiveKit patterns work
POST /realms/fleet/objects/truck1/location
GET  /realms/fleet/objects/truck1
GET  /realms/fleet/objects/nearby

// Enhanced with AI intelligence
POST /realms/fleet/objects/truck1/location?ai_optimize=true
GET  /realms/fleet/objects/truck1?include_predictions=true
GET  /realms/fleet/analytics/intelligence
```

## 📡 REST API Endpoints

### Core Object Management

#### Set Object Location
```http
POST /objects/{key}/location
Content-Type: application/json

{
  "lat": 37.7749,
  "lng": -122.4194,
  "metadata": {
    "speed": 25,
    "heading": 90,
    "type": "delivery_truck"
  },
  "ai_options": {
    "optimize_routing": true,
    "predict_next": true,
    "context_awareness": true
  }
}
```

**AI Enhancement**: Automatically optimizes storage and predicts next location.

**Response**:
```json
{
  "success": true,
  "object_id": "truck1",
  "location": {
    "lat": 37.7749,
    "lng": -122.4194,
    "timestamp": "2024-01-15T14:30:00Z"
  },
  "ai_insights": {
    "predicted_next": {
      "lat": 37.7849,
      "lng": -122.4094,
      "confidence": 0.89,
      "eta": "2024-01-15T14:45:00Z"
    },
    "route_optimization": "Applied traffic-aware routing",
    "anomaly_score": 0.02
  }
}
```

#### Get Object with Intelligence
```http
GET /objects/{key}?include_predictions=true&include_insights=true
```

**Response**:
```json
{
  "object_id": "truck1",
  "current_location": {
    "lat": 37.7749,
    "lng": -122.4194,
    "timestamp": "2024-01-15T14:30:00Z"
  },
  "metadata": {
    "speed": 25,
    "heading": 90,
    "type": "delivery_truck"
  },
  "predictions": {
    "next_1min": {"lat": 37.7759, "lng": -122.4184, "confidence": 0.95},
    "next_5min": {"lat": 37.7789, "lng": -122.4154, "confidence": 0.87},
    "next_15min": {"lat": 37.7849, "lng": -122.4094, "confidence": 0.82}
  },
  "insights": {
    "movement_pattern": "regular_commute",
    "behavior_score": 0.92,
    "risk_assessment": "low",
    "recommendations": ["Optimal route via Highway 101"]
  }
}
```

### Spatial Queries with AI

#### Nearby Search (AI-Optimized)
```http
GET /spatial/nearby?lat=37.7749&lng=-122.4194&radius=1000&ai_optimize=true
```

**Response**:
```json
{
  "query_info": {
    "center": {"lat": 37.7749, "lng": -122.4194},
    "radius": 1000,
    "ai_optimizations_applied": [
      "dynamic_index_selection",
      "predictive_prefetch", 
      "context_filtering"
    ],
    "performance": {
      "query_time_ms": 0.8,
      "objects_scanned": 1250,
      "objects_returned": 15
    }
  },
  "objects": [
    {
      "id": "truck2",
      "location": {"lat": 37.7759, "lng": -122.4184},
      "distance": 127.3,
      "predicted_path": [...],
      "relevance_score": 0.94
    }
  ],
  "ai_insights": {
    "clustering": "Dense area - consider geofence optimization",
    "patterns": "High activity area during rush hours",
    "recommendations": ["Add predictive geofence at 37.7759,-122.4184"]
  }
}
```

#### Within Bounds (Smart Bounding Box)
```http
GET /spatial/within?min_lat=37.77&min_lng=-122.44&max_lat=37.79&max_lng=-122.40&ai_enhance=true
```

### Intelligent Geofencing

#### Create Adaptive Geofence
```http
POST /geofences
Content-Type: application/json

{
  "id": "smart_delivery_zone",
  "geometry": {
    "type": "circle",
    "center": {"lat": 37.7749, "lng": -122.4194},
    "radius": 500
  },
  "rules": {
    "trigger_on": ["enter", "exit"],
    "context_aware": true,
    "adaptive": true
  },
  "ai_settings": {
    "optimize_boundary": true,
    "reduce_false_positives": true,
    "learn_patterns": true,
    "context_factors": ["time", "traffic", "weather"]
  }
}
```

**Response**:
```json
{
  "geofence_id": "smart_delivery_zone",
  "status": "active",
  "ai_optimizations": {
    "boundary_adjusted": true,
    "optimal_radius": 487,
    "confidence_threshold": 0.92,
    "expected_accuracy": 0.96
  },
  "monitoring": {
    "performance_tracking": true,
    "adaptation_enabled": true,
    "learning_active": true
  }
}
```

#### Geofence Analytics
```http
GET /geofences/{id}/analytics?timerange=24h
```

**Response**:
```json
{
  "geofence_id": "smart_delivery_zone",
  "period": "24h",
  "performance": {
    "triggers": 342,
    "false_positives": 8,
    "accuracy": 0.977,
    "avg_response_time": 12
  },
  "ai_insights": {
    "pattern_analysis": "Peak activity 9-11am, 3-5pm",
    "optimization_opportunities": [
      "Expand radius by 3% during peak hours",
      "Add temporal rules for 85% false positive reduction"
    ],
    "learning_progress": "Accuracy improved 12% over 7 days",
    "recommendations": [
      "Enable dynamic radius adjustment",
      "Add weather-based context rules"
    ]
  }
}
```

### Analytics & Intelligence

#### Real-time Intelligence Dashboard
```http
GET /analytics/dashboard?scope=realtime
```

**Response**:
```json
{
  "timestamp": "2024-01-15T14:30:00Z",
  "realtime_metrics": {
    "active_objects": 1247,
    "queries_per_second": 89,
    "geofence_triggers_per_minute": 34,
    "ai_predictions_generated": 156,
    "system_performance": {
      "avg_query_latency_ms": 1.2,
      "ai_processing_overhead": "0.3%",
      "prediction_accuracy": 0.91
    }
  },
  "live_insights": {
    "trending_locations": [
      {"area": "Financial District", "activity_increase": "+23%"},
      {"area": "Mission Bay", "activity_increase": "+15%"}
    ],
    "anomalies_detected": 2,
    "predictions": {
      "next_hour_hotspots": ["Downtown", "SOMA"],
      "traffic_predictions": "Heavy congestion expected at 5pm"
    }
  }
}
```

#### Predictive Analytics
```http
POST /analytics/predictions
Content-Type: application/json

{
  "prediction_type": "location_demand",
  "parameters": {
    "area": {"lat": 37.7749, "lng": -122.4194, "radius": 2000},
    "timeframe": "next_4_hours",
    "confidence_threshold": 0.8
  }
}
```

**Response**:
```json
{
  "prediction_id": "pred_20240115_143000",
  "type": "location_demand",
  "predictions": [
    {
      "time": "15:00-16:00",
      "demand_score": 0.87,
      "hotspots": [
        {"lat": 37.7849, "lng": -122.4094, "intensity": 0.92},
        {"lat": 37.7749, "lng": -122.4294, "intensity": 0.78}
      ]
    }
  ],
  "confidence": 0.84,
  "model_info": {
    "algorithm": "multi_agent_ensemble",
    "training_data": "30_days_historical",
    "factors_considered": ["historical_patterns", "events", "weather", "traffic"]
  },
  "actionable_insights": [
    "Deploy additional resources to Financial District at 3pm",
    "Pre-position vehicles near predicted hotspots"
  ]
}
```

## 🔄 WebSocket Real-time Streams

### Location Updates Stream
```javascript
// Connect to real-time location stream
const ws = new WebSocket('wss://api.example.com/streams/locations');

// Enhanced location events with AI predictions
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  /*
  {
    "type": "location_update",
    "object_id": "truck1",
    "location": {"lat": 37.7759, "lng": -122.4184},
    "timestamp": "2024-01-15T14:31:00Z",
    "ai_enhancements": {
      "movement_vector": {"speed": 25, "heading": 90},
      "predicted_path": [...],
      "anomaly_score": 0.03,
      "context": {"traffic": "moderate", "weather": "clear"}
    }
  }
  */
};
```

### Geofence Events Stream
```javascript
const ws = new WebSocket('wss://api.example.com/streams/geofences');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  /*
  {
    "type": "geofence_trigger",
    "geofence_id": "smart_delivery_zone", 
    "object_id": "truck1",
    "trigger_type": "enter",
    "timestamp": "2024-01-15T14:31:00Z",
    "ai_context": {
      "confidence": 0.96,
      "context_factors": {
        "time_of_day": "afternoon_peak",
        "traffic_condition": "moderate",
        "historical_pattern": "normal"
      },
      "predicted_duration": "18_minutes",
      "recommendations": ["Notify customer of arrival"]
    }
  }
  */
};
```

### AI Insights Stream
```javascript
const ws = new WebSocket('wss://api.example.com/streams/insights');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  /*
  {
    "type": "ai_insight",
    "category": "optimization_opportunity",
    "insight": {
      "title": "Geofence Boundary Optimization",
      "description": "Adjusting delivery zone radius could reduce false positives by 15%",
      "confidence": 0.89,
      "impact_estimate": "15% efficiency gain",
      "recommended_action": {
        "action": "adjust_geofence_radius",
        "geofence_id": "smart_delivery_zone",
        "new_radius": 487,
        "reason": "Optimal balance between coverage and accuracy"
      }
    }
  }
  */
};
```

## 🔧 Redis Protocol Compatibility (Tile38)

For existing Tile38 users, all commands are supported with optional AI enhancements:

### Basic Commands
```redis
# Standard Tile38 commands work unchanged
SET fleet truck1 POINT 37.7749 -122.4194
GET fleet truck1
DEL fleet truck1

# Enhanced with AI (backward compatible)
SET fleet truck1 POINT 37.7749 -122.4194 EX 3600 AI true
GET fleet truck1 WITHFIELDS WITHAI
NEARBY fleet POINT 37.7749 -122.4194 1000 COUNT 10 AI_OPTIMIZE
```

### Geofencing Commands
```redis
# Traditional geofencing
SETHOOK webhook http://example.com/webhook NEARBY fleet POINT 37.7749 -122.4194 500

# AI-enhanced geofencing  
SETHOOK smart_hook http://example.com/webhook NEARBY fleet POINT 37.7749 -122.4194 500 AI_ADAPTIVE true CONFIDENCE 0.9
```

### Search Commands
```redis
# Standard spatial searches
NEARBY fleet POINT 37.7749 -122.4194 1000
WITHIN fleet BOUNDS 37.77 -122.44 37.79 -122.40

# AI-enhanced searches with predictions
NEARBY fleet POINT 37.7749 -122.4194 1000 AI_PREDICT 300 CONFIDENCE 0.8
WITHIN fleet BOUNDS 37.77 -122.44 37.79 -122.40 AI_INSIGHTS
```

## 🔐 Authentication & Security

### API Key Authentication
```http
GET /objects/truck1
Authorization: Bearer ai_api_key_abc123def456
X-AI-Level: enhanced
```

### OAuth2 Integration
```http
POST /oauth/token
Content-Type: application/json

{
  "grant_type": "client_credentials",
  "client_id": "your_client_id",
  "client_secret": "your_client_secret",
  "scope": "geospatial:read geospatial:write ai:enhanced"
}
```

### Rate Limiting with AI Optimization
```http
GET /objects/truck1
Rate-Limit-Remaining: 4950
Rate-Limit-Reset: 3600
AI-Optimization-Credits: 485
```

## 📊 Response Formats

### Standard Format
```json
{
  "success": true,
  "data": {...},
  "metadata": {
    "query_time_ms": 1.2,
    "objects_processed": 150
  }
}
```

### AI-Enhanced Format
```json
{
  "success": true,
  "data": {...},
  "metadata": {
    "query_time_ms": 0.8,
    "objects_processed": 150,
    "ai_optimizations_applied": ["index_selection", "predictive_cache"]
  },
  "ai_insights": {
    "confidence": 0.92,
    "recommendations": [...],
    "predictions": {...},
    "context": {...}
  }
}
```

## ⚡ Performance Guarantees

### SLA Commitments
- **Query Latency**: < 2ms for 95% of spatial queries
- **AI Enhancement Overhead**: < 0.5ms additional processing
- **Geofence Accuracy**: 95%+ with AI optimization
- **Uptime**: 99.9% availability
- **Throughput**: 60,000+ operations per second

### Performance Monitoring
```http
GET /metrics/performance

{
  "current_performance": {
    "avg_query_latency_ms": 0.8,
    "queries_per_second": 7240,
    "ai_enhancement_overhead": 0.3,
    "geofence_accuracy": 0.967,
    "prediction_accuracy": 0.894
  },
  "vs_competitors": {
    "tile38_performance_ratio": 3.2,
    "hivekit_accuracy_improvement": 0.15,
    "unique_ai_capabilities": true
  }
}
```

## 🚀 Getting Started

### Quick Setup
```bash
# Docker deployment
docker run -d \
  --name autogentic-geo \
  -p 8080:8080 \
  -p 6380:6380 \
  -e AI_LEVEL=enhanced \
  autogentic/geospatial-platform:latest

# Test the API
curl -X POST http://localhost:8080/objects/test/location \
  -H "Content-Type: application/json" \
  -d '{"lat": 37.7749, "lng": -122.4194, "ai_options": {"optimize": true}}'
```

### Client SDKs

#### JavaScript/Node.js
```javascript
import { AutogenticGeospatial } from '@autogentic/geospatial-client';

const client = new AutogenticGeospatial({
  endpoint: 'https://api.example.com',
  apiKey: 'your-api-key',
  aiLevel: 'enhanced'
});

// Set location with AI optimization
await client.setLocation('truck1', {
  lat: 37.7749,
  lng: -122.4194,
  aiOptimize: true
});

// Get nearby with predictions
const nearby = await client.nearby({
  lat: 37.7749,
  lng: -122.4194,
  radius: 1000,
  includePredictions: true
});
```

#### Python
```python
from autogentic_geospatial import GeospatialClient

client = GeospatialClient(
    endpoint='https://api.example.com',
    api_key='your-api-key',
    ai_level='enhanced'
)

# Set location with AI optimization
await client.set_location('truck1', {
    'lat': 37.7749,
    'lng': -122.4194,
    'ai_optimize': True
})

# Get intelligent insights
insights = await client.get_analytics(
    scope='realtime',
    include_predictions=True
)
```

## 🎯 Migration Guides

### From Tile38
1. **Keep existing Redis commands** - Full compatibility
2. **Add AI parameters** - Gradually enable AI features
3. **Enhance with WebSocket streams** - Real-time intelligence
4. **Implement geofence intelligence** - Improve accuracy

### From HiveKit
1. **Update endpoints** - Similar REST API structure
2. **Add AI enhancements** - Enable intelligent features
3. **Utilize predictions** - Leverage AI predictions
4. **Optimize performance** - 3x better query performance

This API specification demonstrates how Autogentic's Intelligent Geospatial Platform provides a superior alternative to both Tile38 and HiveKit, with full backward compatibility plus revolutionary AI enhancements.
