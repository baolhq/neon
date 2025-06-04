# NEÖN

A hyper-fast, shader-soaked trip through the cyberspace.

Dodge. Jump. Drift through light.

In NEÖN, you’re a lone runner hurtling through a glowing tunnel of chaos. Your mission? Survive the surge, collect energy orbs, and dodge deadly obstacles by jumping left or right at hyperspeed.

Powered by Love2D shaders, the world of NEÖN pulses with life — bloom, blur, and distortion effects react to your every move. Crank up your reflexes and ride the light.

## Player Manual

1. Jump with `Left/Right Arrow Keys` or `Left Mouse Button`
2. Avoid deadly obstacles and collect as much energies as you can
3. Go back or exit with <code>Esc</code>
4. Pause and resume with <code>Space</code>

## Building

### Dependencies

Before you begin, make sure you have the following installed:

- Lua 5.1 or higher
- Love2D
- Python 3

After you have Python installed on your system, add these following packages for building cross-platforms:

```sh
pip3 install setuptools
pip3 install makelove
```

Then run this command to build

```sh
makelove --config build_config.toml
```

### Installation

Clone the repository:

```sh
git clone https://github.com/baolhq/neon.git
cd neon && code .
```

## Executing

To build and run the project:

- Press `Ctrl+Shift+B` to build using the provided `build_config.toml`, this will generate executables at `/bin` directory
- Or skip to run the project simply with `F5`

## Project Structure

```sh
/neon
├── main.lua                # Entry point
├── conf.lua                # Startup configurations
├── build_config.toml       # Setup for cross-platforms building
├── /lib                    # Third-party libraries
├── /src                    # Game source code
│   ├── entities/           # Game entities
│   ├── global/             # Global variables
│   ├── managers/           # Manage screens, inputs, game states etc..
│   ├── screens/            # Game screens
│   └── util/               # Helper functions
├── /res                    # Static resources
│   ├── img/                # Sprites, textures etc..
│   ├── audio/              # Sound effects
│   └── font/               # Recommended fonts
├── /.vscode                # VSCode launch, debug and build setup
└── /bin                    # Build output
```

## License

This project is licensed under the [MIT License](LICENSE.md). Feel free to customize it whatever you want.
