struct Alimento
    id::Int
    nome::String
    peso_unidade::Float64
    preco::Float64
    calorias::Float64
    proteina::Float64
    gordura::Float64
    carboidrato::Float64
    refeicao::String
    categoria::String
end

function ler_alimentos(arquivo)
    alimentos = Alimento[]

    open(arquivo, "r") do f
        readline(f)

        for line in eachline(f)
            line = strip(line)

            isempty(line) && continue

            parts = split(line, ",")

            id = parse(Int, parts[1])
            nome = strip(parts[2])
            peso_unidade = parse(Float64, parts[3])
            preco = parse(Float64, parts[4])
            calorias = parse(Float64, parts[5])
            proteina = parse(Float64, parts[6])
            gordura = parse(Float64, parts[7])
            carboidrato = parse(Float64, parts[8])
            refeicao = strip(parts[9])
            categoria = strip(parts[10])

            refeicoes = strip.(split(refeicao, '/'))

            for ref in refeicoes
                push!(alimentos, Alimento(
                    id,             
                    nome,
                    peso_unidade,
                    preco,
                    calorias,
                    proteina,
                    gordura,
                    carboidrato,
                    ref,
                    categoria
                ))
            end
        end
    end

    return alimentos
end

function pertence_refeicao(alimento_refeicao::String, refeicao::String)
    refeicao in strip.(split(alimento_refeicao, '/'))
end