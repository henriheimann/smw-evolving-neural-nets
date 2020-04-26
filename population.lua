require "genome"

population = {}

function population.new(size, genome_length)
    local self = {}

    -- private variables:
    local generation = 1
    local genomes = {}

    -- public variables:
    self.max_fitness = 0
    self.min_fitness = 0
    self.avg_fitness = 0
    self.total_fitness = 0

    self.num_elites = 4
    self.cross_rate = 0.7
    self.mut_rate = 0.1
    self.mut_max = 0.3

    -- "tournament" or "roulette"
    self.selection = "roulette"

    -- intialize first generation
    genomes = {}
    for i = 1, size do
        genomes[i] = genome.random(genome_length)
    end

    -- private functions:
    local function select_genome()

        if self.selection == "roulette" then

            local target = math.random() * self.total_fitness
            local passed_fitness = 0

            for i, v in ipairs(genomes) do
                passed_fitness = passed_fitness + v.fitness
                if passed_fitness >= target then
                    return v
                end
            end

            return genomes[1]

        elseif self.selection == "tournament" then

            local competitors = {}
            while #competitors < 4 do
                table.insert(competitors, genomes[math.random(#genomes)])
            end

            table.sort(competitors, function(a, b) return a.fitness > b.fitness end)

            return competitors[1]
        end

        return nil
    end

    -- public functions:
    function self.evolve()
        local new_population = {}

        -- copy elites
        for i=1, self.num_elites do
            new_population[i] = genomes[i]
        end

        -- create the rest by mutation and crossover
        while table.getn(new_population) < table.getn(genomes) do
            local mother = select_genome()
            local father = select_genome()
            local child = mother

            if math.random() < self.cross_rate then
                child = genome.by_crossover(mother, father)
            end
            local mutated = genome.by_mutation(child, self.mut_rate, self.mut_max)
            table.insert(new_population, mutated)
        end

        genomes = new_population
        generation = generation + 1
    end

    function self.recalculate_fitness()
        -- sort genomes by fitness
        table.sort(genomes, function(a, b) return a.fitness > b.fitness end)

        self.max_fitness = genomes[1].fitness
        self.min_fitness = genomes[#genomes].fitness

        self.total_fitness = 0
        for _, v in ipairs(genomes) do
            self.total_fitness = self.total_fitness + v.fitness
        end

        self.avg_fitness = self.total_fitness / table.getn(genomes)
    end

    function self.get_genomes()
        return genomes
    end

    function self.get_genome(index)
        return genomes[index]
    end

    function self.get_size()
        return #genomes
    end

    function self.get_generation()
        return generation
    end

    function self.tostring()
        print("generation", generation);
        print("max_fitness", self.max_fitness)
        print("min_fitness", self.min_fitness)
        print("avg_fitness", self.avg_fitness)
    end

    function self.get_best_genome()
        return genomes[1]
    end

    function self.get_worst_genome()
        return genomes[table.getn(genomes)]
    end

    return self
end
