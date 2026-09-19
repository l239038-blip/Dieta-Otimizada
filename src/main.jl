using JuMP
using HiGHS

include("constant_calculator.jl")
include("variable_reader.jl")

function main()
        
    arquivo1 = joinpath(@__DIR__, "person1.txt")
    arquivo2 = joinpath(@__DIR__, "data.csv")
    
    C_min, C_max, P_min, P_max, G_min, G_max, Carb_min, Carb_max, preferencias, orcamento =
    calcular_constantes(arquivo1)

    println()
    println("Calorias     : $C_min - $C_max kcal")
    println("Proteínas    : $P_min - $P_max g")
    println("Gorduras     : $G_min - $G_max g")
    println("Carboidratos : $Carb_min - $Carb_max g")
    println("Orçamento    : R\$ $(round(orcamento, digits=2))")
    println("Preferências : $(length(preferencias)) itens")
    alimentos = ler_alimentos(arquivo2)

    REFEICOES = ["Cafe da Manha","Almoco","Janta"]

    MIN_ALIMENTOS = 3
    MAX_ALIMENTOS = 5
    MAX_UNIDADES = 3
    MAX_PROTEINAS = 2
    MAX_CARBO = 3
    MAX_GORDURA = 3

    dependencias = [
        ("Bacon","Ovo")
        ("Arroz Cosido","Carne Vermelha")
        ("Macarrao","Frango Grelhado")
        
    ]

    mutuamente_exclusivos = [
        ("Pao","Tapioca")
        ("Arroz Cozido","Macarrao")
        ("Batata Cozida","Batata Frita")
    ]

    n = length(alimentos)

    model = Model(HiGHS.Optimizer)

    set_silent(model)

    # Variaveis
    @variable(model, y[1:n], Bin)
    @variable(model, u[1:n] >= 0, Int)

    for i in 1:n

        @constraint(model,
            u[i] <= MAX_UNIDADES * y[i]
        )

        @constraint(model,
            u[i] >= y[i]
        )

    end

    # Função objetivo __________________________________________________________________________

    @objective(model, Max,
        sum(
            preferencias[alimentos[i].id] * y[i]
            for i in 1:n
        )
    )

    # Restrições __________________________________________________________________________

    @constraint(model,
        C_min <=
        sum(alimentos[i].calorias * alimentos[i].peso_unidade * u[i] for i in 1:n)
        <= C_max
    )

    @constraint(model,
        P_min <=
        sum(alimentos[i].proteina * alimentos[i].peso_unidade * u[i] for i in 1:n)
        <= P_max
    )

    @constraint(model,
        G_min <=
        sum(alimentos[i].gordura * alimentos[i].peso_unidade * u[i] for i in 1:n)
        <= G_max
    )

    @constraint(model,
        Carb_min <=
        sum(alimentos[i].carboidrato * alimentos[i].peso_unidade * u[i] for i in 1:n)
        <= Carb_max
    )

    @constraint(model,
        sum(
            alimentos[i].preco *
            alimentos[i].peso_unidade *
            u[i]
            for i in 1:n
        ) <= orcamento
    )

    # Restrição de quantidade de cada tipo de alimento

    for refeicao in ["Cafe da Manha","Almoco","Janta"]

        idx = [
            i for i in 1:n
            if pertence_refeicao(alimentos[i].refeicao, refeicao) &&
            alimentos[i].categoria == "proteina"
        ]

        @constraint(model,
            sum(y[i] for i in idx) <= MAX_PROTEINAS
        )

        idx = [
            i for i in 1:n
            if pertence_refeicao(alimentos[i].refeicao, refeicao) &&
            alimentos[i].categoria == "carboidrato"
        ]

        @constraint(model,
            sum(y[i] for i in idx) <= MAX_CARBO
        )

        idx = [
            i for i in 1:n
            if pertence_refeicao(alimentos[i].refeicao, refeicao) &&
            alimentos[i].categoria == "gordura"
        ]

        @constraint(model,
            sum(y[i] for i in idx) <= MAX_GORDURA
        )

    end

    for (a,b) in mutuamente_exclusivos

        for refeicao in REFEICOES

            ia = [
                i for i in 1:n
                if alimentos[i].nome == a &&
                alimentos[i].refeicao == refeicao
            ]

            ib = [
                i for i in 1:n
                if alimentos[i].nome == b &&
                alimentos[i].refeicao == refeicao
            ]

            if !isempty(ia) && !isempty(ib)

                @constraint(model,
                    sum(y[i] for i in ia)
                    +
                    sum(y[i] for i in ib)
                    <= 1
                )

            end
        end
    end

    for (a,b) in dependencias

        for refeicao in REFEICOES

            ia = [
                i for i in 1:n
                if alimentos[i].nome == a &&
                alimentos[i].refeicao == refeicao
            ]

            ib = [
                i for i in 1:n
                if alimentos[i].nome == b &&
                alimentos[i].refeicao == refeicao
            ]

            if !isempty(ia) && !isempty(ib)

                @constraint(model,
                    sum(y[i] for i in ia)
                    <=
                    sum(y[i] for i in ib)
                )

            end
        end
    end

    #almoço diferente do jantar

    for id in unique(a.id for a in alimentos)

        idx = [i for i in 1:n if alimentos[i].id == id]

        if length(idx) > 1
            @constraint(model, sum(y[i] for i in idx) <= 1)
        end
    end

    #minimo de alimentos por refeição

    for refeicao in REFEICOES

        idx = [
            i for i in 1:n
            if alimentos[i].refeicao == refeicao
        ]

        @constraint(model,
            MIN_ALIMENTOS <= sum(y[i] for i in idx) <= MAX_ALIMENTOS
        )

    end

    optimize!(model)

    println("Status: ", termination_status(model))

    if termination_status(model) == OPTIMAL

        println("\nDieta encontrada:\n")

        total_cal = 0.0
        total_p = 0.0
        total_g = 0.0
        total_c = 0.0
        total_preco = 0.0

        for refeicao in ["Cafe da Manha", "Almoco", "Janta"]

            println("=== $refeicao ===")

            refeicao_vazia = true

            for i in 1:n
                if value(y[i]) > 0.5 && pertence_refeicao(alimentos[i].refeicao, refeicao)

                    refeicao_vazia = false

                    unidades = Int(round(value(u[i])))
                    quantidade = unidades * alimentos[i].peso_unidade

                    println(
                        "- ", alimentos[i].nome,
                        ": ", unidades,
                        " unidade(s) (",
                        quantidade,
                        " g)"
                    )

                    total_cal += alimentos[i].calorias * quantidade
                    total_p += alimentos[i].proteina * quantidade
                    total_g += alimentos[i].gordura * quantidade
                    total_c += alimentos[i].carboidrato * quantidade
                    total_preco += alimentos[i].preco * quantidade
                end
            end

            if refeicao_vazia
                println("Nenhum alimento selecionado.")
            end

            println()
        end

        println("\nResumo:")
        println("Calorias: ", round(total_cal, digits=1))
        println("Proteínas: ", round(total_p, digits=1), " g")
        println("Gorduras: ", round(total_g, digits=1), " g")
        println("Carboidratos: ", round(total_c, digits=1), " g")
        println("Custo: R\$ ", round(total_preco, digits=2))

    else
        println("Nenhuma solução viável encontrada.")
    end

end

main()