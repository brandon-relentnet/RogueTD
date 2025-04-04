# RogueTD - A Roguelite Deckbuilding Tower Defense

## Game Concept
RogueTD is a roguelite deckbuilding tower defense game where players choose a character archetype, build a deck of tower cards, and defend against waves of enemies across multiple encounters. Each successful encounter allows players to add new cards, upgrade existing ones, or heal their base, creating a strategic progression path through each run.

## Core Gameplay Loop

### Characters/Archetypes
- **Bombardier**: Specializes in explosive, area damage towers (mortars, missile launchers)
- **Engineer**: Focuses on utility towers (slowing fields, buff towers that enhance nearby towers)
- **Sniper**: Precision damage towers that hit hard but have slow attack speed
- **Alchemist**: Poison/DoT effects, splash damage, and status effects
- **Electromancer**: Chain lightning, stuns, and electric-themed towers

### Deck Structure
- Start with 8-10 basic cards specific to your character's archetype
- Maximum deck size of 20-25 cards
- Hand of 4-5 cards per round, draw a new card each turn

### Resources
- Energy system: Start with 3 energy per turn, upgrades can increase this
- Some towers are cheap but basic, others cost more but have special abilities
- Cards could have cooldowns to prevent spam of powerful towers

## Progression

### Run Structure
1. Choose character
2. Navigate a branching path map (like Slay the Spire)
3. Three stages with 3-4 encounters each, culminating in a boss
4. Different paths offer different rewards (card rewards, upgrades, healing)

### Rewards
- **New Cards**: Add a new tower to your deck
- **Upgrades**: Enhance existing towers (reduced cost, increased damage, special effects)
- **Relics/Artifacts**: Permanent run modifiers (all explosive towers deal +20% damage)
- **Health/Recovery**: Repair your base if it took damage

### Tower Upgrades
- Each tower could have 2-3 potential upgrade paths
- Example: Mortar Tower → Heavy Mortar (more damage) OR Rapid Mortar (faster firing) OR Cluster Mortar (splits into smaller bombs)

## Encounter Design

### Regular Encounters
- Short 3-5 round battles with specific enemy compositions
- Some encounters could have special rules (limited energy, pre-placed obstacles)
- Map tiles that modify the encounter (forest: enemies move slower, desert: towers cost more)

### Elite Encounters
- Tougher mid-stage challenges with better rewards
- Special enemy types with unique abilities
- Environmental challenges (shifting terrain, weather effects)

### Boss Encounters
- Large, multi-phase bosses with special abilities
- 8-10 rounds with increasing difficulty
- Require strategic tower placement and timing

## Meta-progression

### Unlockables
- New characters with different starting decks
- Additional cards for each archetype
- Alternate starting decks for existing characters

### Challenge Modes
- Daily challenges with set conditions
- Endless mode for high score chasing
- Scenario challenges with predetermined cards and encounters

## Implementation Plan

### Card System
- Create a Card base class that other tower cards inherit from
- Implement draw and discard piles
- Add hand UI that shows available tower cards

### Tower Placement
- When a player selects a card, show valid placement areas
- Implement energy cost system
- Add visual feedback for tower range and targeting

### Encounter Management
- Design wave-based encounter system
- Create encounter scriptable objects defining enemy types and spawn patterns
- Add special condition modifiers

### Run Progression
- Implement a map screen with node-based path system
- Add reward selection screens
- Create persistent run state that tracks deck, health, relics, etc.

## Development Roadmap

### Phase 1: Core Mechanics
- Basic card system implementation
- Simple tower placement
- Enemy pathing and basic encounters
- One character archetype with starter deck

### Phase 2: Progression & Content
- Add reward system
- Implement tower upgrades
- Create additional character archetypes
- Expand tower and enemy variety

### Phase 3: Run Structure & Polish
- Implement map navigation
- Add boss encounters
- Create meta-progression system
- Balance and polish gameplay
