# Character Memory System - Technical Architecture

## Executive Summary

The Character Memory System is a production-ready AI tool that solves the critical problem of character inconsistency in AI-generated storyboards. By combining persistent character memory with automated consistency validation, it enables filmmakers to generate production-quality storyboards with consistent characters across all frames.

---

## System Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend (React)                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Character   │  │  Storyboard  │  │ Consistency  │      │
│  │   Creator    │  │  Generator   │  │  Validator   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                    REST API (JSON)
                            │
┌─────────────────────────────────────────────────────────────┐
│                  Backend (Python FastAPI)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Character   │  │  Storyboard  │  │  Validator   │      │
│  │   Service    │  │   Service    │  │   Service    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                            │                                 │
│  ┌──────────────────────────────────────────────────┐      │
│  │         OpenAI Client (GPT-4, DALL-E, Vision)    │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                    ┌───────┴────────┐
                    │                │
          ┌─────────▼─────┐   ┌─────▼──────┐
          │   SQLite DB    │   │   Image    │
          │   (Metadata)   │   │   Storage  │
          └────────────────┘   └────────────┘
```

---

## Core Components

### 1. Character Service

**Purpose**: Manages character creation, storage, and "DNA" extraction.

**Key Responsibilities**:
- Process uploaded reference images (1-3 photos)
- Extract visual features using OpenAI Vision API
- Generate persistent character embeddings ("Character DNA")
- Create optimized prompts for consistent generation
- Store and retrieve character profiles

**Technical Implementation**:

```python
class CharacterService:
    def create_character(self, images: List[bytes], name: str, description: str):
        """
        Creates a new character with persistent identity.
        
        Process:
        1. Preprocess images (resize, normalize)
        2. Extract features via Vision API
        3. Generate character DNA (embeddings)
        4. Create base prompt template
        5. Store in database
        """
        
    def extract_visual_dna(self, images: List[bytes]) -> dict:
        """
        Uses OpenAI Vision API to extract detailed character features.
        Returns structured embedding of visual characteristics.
        """
        
    def get_character_prompt(self, character_id: str) -> str:
        """
        Retrieves optimized prompt for consistent character generation.
        Format: "{name}, {features}, consistent character, high quality"
        """
```

**Data Model**:
```python
Character {
    id: UUID
    name: str
    description: str
    reference_images: List[str]  # File paths
    visual_dna: dict             # Feature embeddings
    base_prompt: str             # Optimized generation prompt
    metadata: dict
    created_at: datetime
}
```

---

### 2. Storyboard Service

**Purpose**: Generates complete storyboards with consistent characters.

**Key Responsibilities**:
- Parse story scripts into individual scenes
- Use GPT-4 to enhance scene descriptions
- Generate images with character consistency via DALL-E
- Manage multi-character scenes
- Handle scene-specific requirements

**Technical Implementation**:

```python
class StoryboardService:
    def generate_storyboard(self, script: str, character_ids: List[str], 
                           title: str) -> Storyboard:
        """
        Complete storyboard generation pipeline.
        
        Process:
        1. Parse script into scenes using GPT-4
        2. Load character DNA for all characters
        3. Generate enhanced scene descriptions
        4. Create images with consistent characters
        5. Assemble and store storyboard
        """
        
    def parse_script(self, script: str) -> List[Scene]:
        """
        Uses GPT-4 to intelligently parse script into scenes.
        Identifies: location, action, characters present, mood
        """
        
    def generate_scene_image(self, scene: Scene, characters: List[Character]) -> bytes:
        """
        Generates single scene with character consistency.
        Combines scene description + character DNA prompts.
        """
```

**Scene Generation Algorithm**:
```
Input: Scene description + Character DNA
↓
1. Combine character prompts with scene description
   Example: "Emma (red hair, leather jacket, consistent character) 
            investigating crime scene in dark alley, film noir lighting"
↓
2. Call DALL-E 3 with enhanced prompt
↓
3. Post-process image (resize, optimize)
↓
4. Return generated frame
```

---

### 3. Consistency Validator

**Purpose**: Analyzes storyboards for character consistency and provides actionable feedback.

**Key Responsibilities**:
- Extract features from generated frames
- Compare against original character DNA
- Calculate similarity scores (cosine similarity)
- Generate detailed consistency reports
- Identify frames requiring regeneration

**Technical Implementation**:

```python
class ValidatorService:
    def validate_storyboard(self, storyboard_id: str) -> ValidationReport:
        """
        Full consistency analysis of a storyboard.
        
        Process:
        1. Load storyboard and original characters
        2. For each frame: extract features with Vision API
        3. Calculate similarity scores vs. character DNA
        4. Generate comprehensive report
        5. Flag problematic frames (<80% similarity)
        """
        
    def calculate_similarity(self, frame_features: dict, 
                            character_dna: dict) -> float:
        """
        Computes cosine similarity between frame and original DNA.
        Returns score from 0-100.
        """
        
    def generate_report(self, scores: List[float]) -> dict:
        """
        Creates detailed validation report with:
        - Overall consistency score
        - Per-frame breakdown
        - Flagged frames
        - Regeneration recommendations
        """
```

**Consistency Scoring Algorithm**:
```
For each frame in storyboard:
  1. Extract visual features (Vision API)
     → Feature vector F
  
  2. Load original character DNA
     → DNA vector D
  
  3. Calculate cosine similarity:
     similarity = (F · D) / (||F|| * ||D||)
     score = similarity * 100
  
  4. Classify result:
     - score ≥ 85%: Excellent
     - score 70-84%: Good
     - score < 70%: Needs regeneration

Overall Score = Average of all frame scores
```

---

## Data Flow Architecture

### Complete User Workflow

**Phase 1: Character Creation**
```
User uploads images → Frontend
                    ↓
        POST /api/characters
                    ↓
        Character Service
                    ↓
        OpenAI Vision API (feature extraction)
                    ↓
        Generate Character DNA
                    ↓
        Store in Database + Images
                    ↓
        Return Character ID
```

**Phase 2: Storyboard Generation**
```
User writes script + selects characters → Frontend
                                        ↓
                      POST /api/storyboards
                                        ↓
                       Storyboard Service
                                        ↓
            GPT-4 (parse script into scenes)
                                        ↓
        For each scene:
          Load Character DNA
                ↓
          Combine with scene description
                ↓
          DALL-E 3 (generate image)
                ↓
          Store frame
                                        ↓
                    Return complete storyboard
```

**Phase 3: Consistency Validation**
```
User requests validation → Frontend
                         ↓
        POST /api/validate/{storyboard_id}
                         ↓
           Validator Service
                         ↓
        For each frame:
          Extract features (Vision API)
                ↓
          Calculate similarity score
                ↓
          Collect results
                         ↓
        Generate report with scores
                         ↓
        Return validation results
```

---

## Database Schema

### Tables and Relationships

**Characters Table**
```sql
CREATE TABLE characters (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    reference_images TEXT,      -- JSON array of file paths
    visual_dna TEXT,            -- JSON feature embeddings
    base_prompt TEXT,
    metadata TEXT,              -- JSON additional data
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Storyboards Table**
```sql
CREATE TABLE storyboards (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    script TEXT NOT NULL,
    character_ids TEXT,         -- JSON array of character IDs
    scenes TEXT,                -- JSON array of scene data
    status TEXT DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Validation Results Table**
```sql
CREATE TABLE validation_results (
    id TEXT PRIMARY KEY,
    storyboard_id TEXT NOT NULL,
    overall_score REAL,
    frame_scores TEXT,          -- JSON array of individual scores
    report TEXT,                -- JSON detailed report
    validated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (storyboard_id) REFERENCES storyboards(id)
);
```

---

## API Specification

### Character Endpoints

**POST /api/characters**
```json
Request:
{
  "name": "Emma Detective",
  "description": "Female detective, 30s, red hair",
  "images": ["base64_image_1", "base64_image_2"]
}

Response:
{
  "id": "char_abc123",
  "name": "Emma Detective",
  "visual_dna": {...},
  "base_prompt": "Emma Detective, red hair, leather jacket...",
  "created_at": "2026-01-15T10:30:00Z"
}
```

**GET /api/characters**
```json
Response:
{
  "characters": [
    {
      "id": "char_abc123",
      "name": "Emma Detective",
      "thumbnail": "/images/char_abc123_thumb.jpg",
      "created_at": "2026-01-15T10:30:00Z"
    }
  ]
}
```

### Storyboard Endpoints

**POST /api/storyboards**
```json
Request:
{
  "title": "Detective Mystery",
  "script": "Scene 1: Emma enters the crime scene...",
  "character_ids": ["char_abc123"]
}

Response:
{
  "id": "story_xyz789",
  "title": "Detective Mystery",
  "scenes": [
    {
      "scene_number": 1,
      "description": "Emma enters the crime scene",
      "image_url": "/images/story_xyz789_scene1.jpg"
    }
  ],
  "status": "completed"
}
```

**POST /api/storyboards/{id}/regenerate-frame**
```json
Request:
{
  "scene_number": 3,
  "reason": "Low consistency score"
}

Response:
{
  "scene_number": 3,
  "new_image_url": "/images/story_xyz789_scene3_v2.jpg",
  "message": "Frame regenerated successfully"
}
```

### Validation Endpoints

**POST /api/validate/{storyboard_id}**
```json
Response:
{
  "storyboard_id": "story_xyz789",
  "overall_score": 87.5,
  "frame_scores": [
    {"frame": 1, "score": 92.3, "status": "excellent"},
    {"frame": 2, "score": 85.1, "status": "good"},
    {"frame": 3, "score": 68.4, "status": "needs_review"}
  ],
  "recommendations": [
    "Regenerate frame 3 for better consistency"
  ]
}
```

---

## Technology Stack

### Backend Technologies

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Framework** | FastAPI 0.109+ | Modern async API framework |
| **AI Services** | OpenAI Python SDK | GPT-4, DALL-E 3, Vision API |
| **Image Processing** | Pillow, OpenCV | Image manipulation |
| **Vector Operations** | NumPy, scikit-learn | Similarity calculations |
| **Database** | SQLite 3 | Lightweight persistent storage |
| **Validation** | Pydantic | Request/response validation |

### Frontend Technologies

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Framework** | React 18 | UI framework |
| **Build Tool** | Vite 5 | Fast development and bundling |
| **Styling** | Tailwind CSS | Utility-first CSS |
| **UI Components** | shadcn/ui | Pre-built components |
| **State Management** | Zustand | Lightweight state |
| **HTTP Client** | Axios | API communication |
| **File Upload** | react-dropzone | Image upload handling |

### AI Services (OpenAI)

| Service | Model | Purpose |
|---------|-------|---------|
| **Text Generation** | GPT-4 Turbo | Script parsing, scene descriptions |
| **Image Generation** | DALL-E 3 | Character-consistent storyboard frames |
| **Vision Analysis** | GPT-4 Vision | Feature extraction, consistency validation |

---

## Performance Considerations

### Optimization Strategies

1. **Image Caching**
   - Store generated images locally
   - Reuse character reference images
   - Cache Vision API responses

2. **Batch Processing**
   - Generate multiple scenes in parallel
   - Batch validation requests
   - Optimize database queries

3. **Rate Limiting**
   - Implement exponential backoff for API calls
   - Queue management for generation requests
   - User request throttling

### Expected Performance

| Operation | Target Time | Notes |
|-----------|-------------|-------|
| Character Creation | 10-15 seconds | 3 images, feature extraction |
| Scene Generation | 20-30 seconds | Per frame with DALL-E 3 |
| 10-Frame Storyboard | 4-6 minutes | Parallel generation |
| Consistency Validation | 15-25 seconds | All frames analyzed |

---

## Security Considerations

### API Key Management
- Store OpenAI API keys in environment variables
- Never commit keys to version control
- Use `.env` files for local development
- Implement key rotation policies

### Data Privacy
- Store images locally (no cloud uploads except OpenAI)
- Implement user authentication for production
- Clear temporary files after processing
- GDPR-compliant data handling

### Input Validation
- Validate file types and sizes
- Sanitize user inputs (script text)
- Rate limit API endpoints
- Implement CORS policies

---

## Scalability Path

### Phase 1: MVP (Hackathon)
- Single-user local deployment
- SQLite database
- Local image storage
- Synchronous processing

### Phase 2: Multi-User
- PostgreSQL database
- Cloud storage (S3/GCS)
- User authentication
- Async job processing

### Phase 3: Production
- Kubernetes deployment
- Redis caching
- CDN for images
- Multiple AI provider support

---

## Error Handling Strategy

### API Error Handling
```python
try:
    response = await openai_client.generate_image(prompt)
except RateLimitError:
    # Exponential backoff and retry
    await asyncio.sleep(exponential_backoff())
    return await retry_with_backoff()
except InvalidRequestError:
    # Log error and provide user feedback
    return {"error": "Invalid request parameters"}
except Exception as e:
    # Catch-all for unexpected errors
    log_error(e)
    return {"error": "Unexpected error occurred"}
```

### User-Facing Errors
- Provide clear, actionable error messages
- Suggest fixes for common issues
- Graceful degradation (continue with available data)
- Retry mechanisms for transient failures

---

## Testing Strategy

### Unit Tests
- Character DNA extraction accuracy
- Scene parsing logic
- Similarity score calculations
- Database operations

### Integration Tests
- Full character creation workflow
- End-to-end storyboard generation
- Validation report generation
- API endpoint testing

### Demo Scenarios
1. **Single Character Storyboard**: 5 scenes, one character
2. **Multi-Character Scene**: 2-3 characters in same frame
3. **Consistency Edge Cases**: Extreme lighting, angles
4. **Regeneration Workflow**: Fix low-consistency frames

---

## Monitoring and Logging

### Key Metrics to Track
- API response times
- OpenAI API usage and costs
- Character consistency scores
- User workflow completion rates
- Error rates by type

### Logging Strategy
```python
import logging

logger = logging.getLogger(__name__)

# Log levels:
# DEBUG: Detailed diagnostic info
# INFO: Workflow milestones
# WARNING: Consistency scores < 70%
# ERROR: API failures, exceptions
# CRITICAL: System-level failures
```

---

## Future Enhancements

### Planned Features
1. **Video Storyboards**: Animate frames into preview videos
2. **Style Transfer**: Apply consistent art styles
3. **Multi-Model Support**: Integrate Stable Diffusion, Midjourney
4. **Collaboration Tools**: Share storyboards, team workspaces
5. **Export Formats**: PDF, FCP XML, Adobe Premiere

### Research Directions
- Fine-tuned models for character consistency
- Real-time consistency prediction
- Automated scene composition
- 3D character model generation

---

## References

- OpenAI API Documentation: https://platform.openai.com/docs
- FastAPI Documentation: https://fastapi.tiangolo.com
- React Best Practices: https://react.dev
- Film Production Workflows: Industry standards

---

**Last Updated**: January 15, 2026
**Version**: 1.0.0
**Authors**: Hackathon Team
