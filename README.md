# Solar 2D Endless Runner

A side-scrolling endless runner built with [Solar 2D](https://solar2d.com) (formerly Corona SDK) and Lua. Jump over obstacles, survive as long as possible, and beat your high score.

## Features

- Physics-based character with jump mechanic (tap to jump)
- Procedurally generated platforms at varying heights and gaps
- Random obstacle spawning on platforms
- Increasing scroll speed over time — the longer you survive, the harder it gets
- In-session high score tracking
- Instant restart after game over

## Controls

| Input | Action |
|-------|--------|
| Tap / Click | Jump (only when grounded) |

## Project Structure

```
solar2d-endless-runner/
├── config.lua      # Display resolution and scaling config
└── main.lua        # All game logic: physics, spawning, scoring, input
```

## Getting Started

### Prerequisites

1. Download the [Solar 2D simulator](https://github.com/coronalabs/corona/releases) (free, macOS/Windows/Linux)
2. No additional libraries required — all APIs are built into Solar 2D

### Run the game

1. Open the Solar 2D simulator
2. **File → Open** → select the `solar2d-endless-runner/` folder
3. The simulator launches the game immediately

### Building for device (optional)

- iOS / Android builds require a Solar 2D Enterprise or Plugins account
- For local testing the simulator is sufficient

## Tech Stack

- **Engine**: Solar 2D (Corona SDK) 2024.x
- **Language**: Lua 5.1
- **Physics**: Solar 2D built-in Box2D wrapper
