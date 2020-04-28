require "genome"
require "population"
require "neuralnet"
require "smw_io"

local MOVEMENT_TIMEOUT      = 30 * 15
local PROGRESS_TIMEOUT      = 30 * 30

local SAVE_STATES           = { 1 }

local INPUT_RADIUS          = 6

local POPULATION_SIZE       = 30

local BUTTONS               = { "A", "B", "X", "Y", "right", "left", "down", "up" }

local NUM_INPUTS            = smw_io.get_num_inputs(INPUT_RADIUS) + 1
local NUM_OUTPUTS           = #BUTTONS
local LAYER_SIZES           = { NUM_INPUTS, 16, 8, NUM_OUTPUTS }
local NUM_WEIGHTS           = neuralnet.get_num_weights(LAYER_SIZES)

local current_population    = population.new(POPULATION_SIZE, NUM_WEIGHTS)
local current_state_index   = #SAVE_STATES
local current_genome_index  = 0
local current_neuralnet     = nil

local total_frames          = 0
local last_movment_counter  = 0
local last_progress_counter = 0
local last_mx               = 0
local last_my               = 0
local max_mx                = 0
local max_my                = 0
local start_mx              = 0
local start_my              = 0
local mx                    = 0
local my                    = 0

local global_max_fitness    = 0

local function initialize_next_test()

    if current_state_index >= #SAVE_STATES then
        if current_genome_index >= current_population.get_size() then
            current_population.recalculate_fitness()

            -- print current generation results
            print(current_population.tostring())

            current_population.evolve()
            current_genome_index = 1
        else
            current_genome_index = current_genome_index + 1
        end

        current_population.get_genome(current_genome_index).fitness = 0
        current_neuralnet = neuralnet.new(LAYER_SIZES, current_population.get_genome(current_genome_index).get_genes())
        current_state_index = 1
    else
        current_state_index = current_state_index + 1
    end

    if current_genome_index == 1 then
        emu.speedmode("normal")
    else
        emu.speedmode("nothrottle")
    end

    local state = savestate.create(SAVE_STATES[current_state_index])
    savestate.load(state)

    mx, my = smw_io.get_mario_pos()
    last_mx, last_my = mx, my
    max_mx, max_my = mx, my
    start_mx, start_my = mx, my

    total_frames = 0
    last_movment_counter = 0
    last_progress_counter = 0
end

local function complete_test()

    local fitness = max_mx - start_mx

    --if max_mx >= math.sqrt(5000) then
    --    fitness = fitness + smw_io.get_timer()
    --end

    current_population.get_genome(current_genome_index).fitness =
        current_population.get_genome(current_genome_index).fitness + fitness

    if current_state_index == #SAVE_STATES then
        -- Update global max fitness
        global_max_fitness = math.max(math.floor(current_population.get_genome(current_genome_index).fitness), global_max_fitness)
    end

    initialize_next_test()
end

local function update()

    gui.text(2, 215, "GEN: "..current_population.get_generation().." - GENOME "..current_genome_index.."/"
        ..POPULATION_SIZE.." - MAX FIT: "..global_max_fitness)

    mx, my = smw_io.get_mario_pos()

    local inputs = smw_io.get_inputs(INPUT_RADIUS)
    table.insert(inputs, math.sin(total_frames / 60 * math.pi))

    local outputs = current_neuralnet.gen_outputs(inputs)

    local buttons_pressed = {}
    for i = 1, #outputs do
        if outputs[i] > 0.5 then
            buttons_pressed[BUTTONS[i]] = true
            gui.text(2, 64 + i * 8, string.upper(BUTTONS[i]))
        end
    end
    joypad.set(1, buttons_pressed)

    total_frames = total_frames + 1

    if mx == 0 and my == 0 then
        complete_test("death or completed level")
    end

    if mx > max_mx then
        last_progress_counter = 0
    else
        last_progress_counter = last_progress_counter + 1
        if last_progress_counter > PROGRESS_TIMEOUT then
            complete_test("progress timeout")
        end
    end

    if mx > max_mx then max_mx = mx end
    if my > max_my then max_my = my end

    if last_mx ~= mx or last_my ~= my then
        last_mx = mx
        last_my = my
        last_movment_counter = 0
    else
        last_movment_counter = last_movment_counter + 1
        if last_movment_counter > MOVEMENT_TIMEOUT then
            complete_test("movement timeout")
        end
    end
end

initialize_next_test()
while true do
    smw_io.debug(INPUT_RADIUS)
    --smw_io.debug_sprites()
    update()
    emu.frameadvance()
end
