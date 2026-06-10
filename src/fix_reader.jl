struct Pessoa
    sexo::String
    idade::Int
    peso::Float64
    altura::Float64
    nivel_exercicio::String
    Objetivo::String
    orcamento::Int
    preferencias::Vector{Int}
end

function ler_pessoa(arquivo)
    open(arquivo, "r") do io
        dados = split(readline(io))

        sexo = dados[1]
        idade = parse(Int, dados[2])
        peso = parse(Float64, dados[3])
        altura = parse(Float64, dados[4])
        nivel_exercicio = dados[5]
        Objetivo = dados[6]
        orcamento = parse(Int, dados[7])

        n = parse(Int, readline(io))

        preferencias = [parse(Int, strip(readline(io))) for _ in 1:n]

        return Pessoa(
            sexo,
            idade,
            peso,
            altura,
            nivel_exercicio,
            Objetivo,
            orcamento,
            preferencias
        )
    end
end