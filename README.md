# Escape Plan

A Godot-based adventure game where players must rescue prisoners and escape from various scenarios using stealth, strategy, and puzzle-solving.

## Project Overview

This is a 2D top-down adventure game built with Godot Engine featuring:
- Player character with movement and interaction mechanics
- Multiple enemy types (cats, dinosaurs, slimes, snails)
- Mission-based gameplay (rescue prisoners, collect keys, unlock cages)
- Multiple maps and scenarios
- UI system with menus (main menu, pause menu, win/lose screens, settings)
- Sound effects and background music
- Animation system for characters
- Navigation and pathfinding system

## Project Structure

```
escape-plan/
├── assets/               # Game assets
│   ├── animation/       # Character animations
│   ├── items/          # Item sprites and tilesets
│   ├── sounds/         # Audio files (music and SFX)
│   ├── sprites/        # Character and object sprites
│   └── tiles/          # Tileset collections
├── scenes/              # Godot scene files (.tscn)
│   ├── characters/     # Player and NPC scenes
│   ├── core/           # Core game systems
│   ├── enemy/          # Enemy scenes and behaviors
│   ├── maps/           # Game level/map scenes
│   ├── mission/        # Mission-related scenes
│   └── ui/             # UI menu scenes
├── scripts/             # GDScript code files
│   ├── ai/             # Enemy AI and NPC AI
│   ├── enemy/          # Enemy controllers
│   ├── managers/       # Game managers
│   ├── mission/        # Mission system
│   ├── player/         # Player mechanics
│   ├── rooms/          # Room management
│   ├── ui/             # UI logic
│   └── util/           # Utility functions
└── window_version/      # Exported game builds
```

## Getting Started

### Requirements
- **Godot Engine** 4.x or compatible version
- Asset files (sprites, sounds, tilesets included)

### Running the Project

1. **Open in Godot:**
   - Launch Godot Engine
   - Open the project folder containing `project.godot`

2. **Run the Game:**
   - Click the "Play" button or press F5 to run the game
   - Main menu will display on startup

3. **Export:**
   - Use Godot's export function to build for Windows, Web, or other platforms
   - Exported version is available in `window_version/`

## Game Features

### Player Mechanics
- Movement in 8 directions
- Interaction with objects (keys, cages, NPCs)
- Health system with heart UI
- Sound effects for movement and actions

### Enemy Types
- **Cat Enemy** - Aggressive pursuer
- **Dinosaur** - Patrol-based enemy
- **Slime** - Bouncing enemy with physics
- **Snail** - Slow-moving enemy

### Mission System
- Rescue prisoners from cages
- Collect keys to unlock obstacles
- Navigate through multiple maps
- Win/Lose conditions

### UI Features
- Main Menu
- Pause Menu
- Settings Menu
- Instruction/Help Menu
- Minimap for navigation
- Health/heart display
- Win/Lose screens

## Controls

| Action | Input |
|--------|-------|
| Move | Arrow Keys / WASD |
| Interact | E / Space |
| Pause | ESC |
| Menu Navigate | Arrow Keys |
| Confirm | Enter / Space |

## Key Scripts

### Core Systems
- `navigation_system.gd` - Pathfinding and navigation
- `room_manager.gd` - Scene and room transitions
- `auto_connect.gd` - Autoload/singleton setup
- `waypoint_manager.gd` - Waypoint management

### Game Logic
- `player/*.gd` - Player controller and mechanics
- `enemy/*_controller.gd` - Enemy behavior systems
- `mission/mission_system.gd` - Mission management

### UI
- `ui/*.gd` - Menu controllers (main, pause, settings, etc.)

## Assets

### Sprites Used
- 8-Direction Characters
- Farmer, Pirate, Cat, Dino characters
- Various enemy sprites
- UI elements (hearts, cage, key, lock)
- Smoke and particle effects

### Audio
- Background music (126 Alice.mp3)
- Sound effects:
  - Attack sounds (attack_meow, fire-whooshing)
  - Player SFX (player_walking, mc-hurt)
  - Environmental (drowning, water-splash, smoke)
  - Enemy sounds (slime-bounce, meow)

### Tilesets
- Farm and Tree Tiles
- Kenny-Pirate Tiles
- Mystic Wood Tiles
- Template-like Tiles

## Development Notes

- Game uses Godot's 2D physics system
- Navigation system handles pathfinding for AI
- Mission system tracks objectives and game state
- Multiple enemy controllers for different behavior types
- Modular UI system for easy menu management

## Build & Export

### Running from window_version/

A prebuilt Windows version is available in the `window_version/` folder. This contains the compiled game ready to play:

**Files in window_version/:**
- `EscapePlan.exe` - Main executable file (run this to play the game)
- `EscapePlan.pck` - Game data and resources (required by the executable)
- `export_presets.cfg` - Export configuration file (for re-exporting)

**How to Run the Game:**

1. **Navigate to the folder:**
   - Open File Explorer
   - Go to: `escape-plan/window_version/`

2. **Run the game:**
   - Double-click `EscapePlan.exe` to launch the game
   - The game window will open and display the main menu

3. **Playing the Game:**
   - Use arrow keys or WASD to move
   - Press E or Space to interact with objects
   - Press ESC to open the pause menu
   - Complete missions and reach the rescue point to win

**Alternative: Export from Godot**

If you want to re-export or create a new build:
1. Open the project in Godot
2. Go to `Project → Export...`
3. Select the Windows Desktop preset
4. Click `Export Project`
5. Choose the `window_version/` folder as the destination
6. Godot will create updated `EscapePlan.exe` and `EscapePlan.pck` files

**System Requirements (Windows):**
- Windows 7 or later
- No additional installation required
- Can run directly without Godot Engine installed

## Future Enhancements

- Additional levels and maps
- More enemy types and AI behaviors
- Enhanced puzzle mechanics
- Multiplayer features
- Mobile platform support
- Difficulty settings

## License

[Add your license information here]

## Credits

- **Engine:** Godot Engine
- **Assets:** Various free asset packs (Kenny, Mystic Woods, etc.)

---

For more information or to contribute, please contact the development team.
