# Changelog

## 0.1.1

Add more resources to the game, more juices!

- Add gun sprite and implement gun rotations
- Add many sound effects
- Remove unused sounds
- Add healthbar, particles for enemies
- Add screenshakes

## 0.1.0

Major refactoring, implement i-frames logics

- Add i-frames when the player touches an enemy
- Move `managers.input_manager` to just `utils.input`
- Add actual settings menu

## 0.0.4

Refactoring models for simplicity, keyboard and mouse UI navigations

- Clean up clutter codes in model table
- Separate mouse with keyboard navigation for smoother UX
- Minor bug fixes

## 0.0.3

Some minor refactoring, add global input manager for sanity

- Add input manager
- Change button state from `focused` and `hovered` to a unified `active`
- Update button styles

## 0.0.2

A basic working prototype of the game

- Add bullet and enemy logics
- Implement enemy object pooling and movements
- Add simple enemy wave logic
- Add basic AABB collision detection
- **Add enemy repulsive force to prevent overlap with each other**

## 0.0.1

Not so much going on, just bringin' some stuff from my old project over.

- Add title, main and settings screen
- Add screen manager for easier switching
- Add cross-plarforms build support
- Add many utility functions
- Add global constants for for easier management
- Some placeholder audio and images that I'll change later
