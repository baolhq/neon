# NEÖN

In NEÖN, you’re a lone runner hurtling through a glowing tunnel of chaos. Your mission? Survive the surge, collect energy orbs, and dodge deadly obstacles by jumping left or right at hyperspeed.

Powered by [moonshine](https://github.com/vrld/moonshine) shaders, the world of NEÖN pulses with life — bloom, blur, and distortion effects react to your every move. Crank up your reflexes and ride the light.

Made with LÖVE™.

## Player Manual

1. Control: `A` or `Left` and `D` or `Right` to jump
2. Mouse: `Left Button` to also jump.
3. Menu: `Tab` or `Up` and `Down` to navigate menu
4. Action: `Space` or `Enter` to pause/resume or restart, `Esc` to go back

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

### Installation

Clone the repository:

```sh
git clone https://github.com/baolhq/neon.git
cd neon && code .
```

Then run this command to build

```sh
makelove --config build_config.toml
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
├── /.vscode                # VSCode launch, debug and build setup
├── /lib                    # Third-party libraries
├── /res                    # Static resources
├── /src                    # Game source code
│   ├── models/             # Game entities
│   ├── globals/            # Global variables
│   ├── managers/           # Manage screens, inputs, game states etc..
│   ├── scenes/             # Game scenes
│   └── utils/              # Helper functions
└── /bin                    # Build output
```

## License

This project is licensed under the [MIT License](LICENSE.md). Feel free to customize it whatever you want.
