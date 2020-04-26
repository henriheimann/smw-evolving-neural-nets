genome = {}

function genome.new(genes)
    local self = {}

    -- public variables:
    self.fitness = 0

    -- public functions:
    function self.get_genes()
        return genes
    end

    function self.get_gene(index)
        return genes[index]
    end

    function self.get_length()
        return #genes
    end

    function self.tostring()
        for k, v in pairs(genes) do
            print(k, v)
        end
        print("fitness", self.fitness)
    end

    return self
end

function genome.random(length)
    local genes = {}

    for i=1, length do
        genes[i] = math.random() - math.random()
    end

    return genome.new(genes)
end

function genome.by_mutation(source, mut_rate, mut_max)
    local genes = {}

    for i=1, source.get_length() do
        genes[i] = source.get_gene(i)
        if math.random() < mut_rate then
            genes[i] = genes[i] + math.random() * mut_max
            genes[i] = genes[i] - math.random() * mut_max
            if genes[i] > 1 then
                genes[i] = 1
            elseif genes[i] < -1 then
                genes[i] = -1
            end
        end
    end

    return genome.new(genes)
end

function genome.by_crossover(mother, father)
    local genes = {}
    local length = mother.get_length()
    local point = math.random(length)

    if length ~= father.get_length() then
        return nil
    end

    for i=1, length do
        if i < point then
            genes[i] = mother.get_gene(i)
        else
            genes[i] = father.get_gene(i)
        end
    end

    return genome.new(genes)
end
