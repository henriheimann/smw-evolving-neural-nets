# Evolving Neural Nets to play Super Mario World

I developed this project in 2015 inspired by SethBling's [MarI/O](https://www.youtube.com/watch?v=qv6UVOQ0F44). While MarI/O only gave the neural net information about wether a tile around Mario was occupied or not as input, I wanted to provide it with information about occupancy and a positive / negative indicator about positive (Power-Ups) and negative sprites (Goombas, etc.). My implementation uses a genetic algorithm evolving the weights of a simple feed forward network.

## Setup

- Download the rerecording version of [Snes9x](http://tasvideos.org/EmulatorResources/Snes9x.html) (Lua scripting is only supported on Windows)
- Obtain a copy of the Super Mario World (USA) ROM
- Start any level and immediately save the state in Slot 1
- Run `program.lua`

## Execution

While the program is running, it will always show the best genome of each generation in real time, the evaluation runs of the following genomes will be sped-up.

The screenshot below shows the (debugging) overlay which is drawn. The map in the upper left corner shows the current input and bounding box overlays are drawn for each sprite. The current controller input (the neural networks output) is shown on the right.

![Case Design](/Documentation/screenshots.jpg)

## Configuration

```lua
-- Timeout to stop evaluation of genome with no movement
local MOVEMENT_TIMEOUT      = 30 * 5

-- Timeout to stop evaluation of genome no longer moving right
local PROGRESS_TIMEOUT      = 30 * 20

-- The save states to train the genomes on
local SAVE_STATES           = { 1 }

-- The radius around the player to use as input for the neural net
local INPUT_RADIUS          = 6

-- The population size of the genetic algorithm
local POPULATION_SIZE       = 20

-- The topology of the neural net: NUM_INPUTS and NUM_OUTPUTS are fixed
local LAYER_SIZES           = { NUM_INPUTS, 16, 12, NUM_OUTPUTS }
```