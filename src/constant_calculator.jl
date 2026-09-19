include("fix_reader.jl")

function calcular_constantes(arquivo)
    pessoa = ler_pessoa(arquivo)

    sexo = pessoa.sexo
    idade = pessoa.idade
    peso = pessoa.peso
    altura = pessoa.altura
    nivel_exercicio = pessoa.nivel_exercicio
    objetivo = pessoa.Objetivo
    preferencias = pessoa.preferencias

    # Taxa metabólica basal (Mifflin-St Jeor)
    tmb = (10 * peso) + (6.25 * altura) - (5 * idade) +
          (sexo == "M" ? 5 : -161)

    # Fator de atividade
    fa = nivel_exercicio == "S" ? 1.20 :
         nivel_exercicio == "L" ? 1.375 :
         nivel_exercicio == "M" ? 1.55 :
         nivel_exercicio == "A" ? 1.72 :
         error("nível de exercício inválido")

    get = tmb * fa

    # Faixa calórica conforme objetivo
    C_min, C_max = if objetivo == "E"       # Emagrecimento
        (get - 500, get - 300)
    elseif objetivo == "M"                 # Manutenção
        (get - 100, get + 100)
    elseif objetivo == "G"                 # Ganho de massa
        (get + 300, get + 500)
    else
        error("objetivo inválido")
    end

    # Proteínas (g/kg)
    P_fator_min, P_fator_max = if nivel_exercicio == "S"
        (0.8, 1.0)
    elseif nivel_exercicio == "L"
        (1.2, 1.5)
    elseif nivel_exercicio in ["M", "A"]
        (1.2, 2.0)
    end

    P_min = peso * P_fator_min
    P_max = peso * P_fator_max

    # Carboidratos (g/kg)
    Carb_fator_min, Carb_fator_max = if nivel_exercicio == "S"
        (3.0, 5.0)
    elseif nivel_exercicio in ["L", "M"]
        (5.0, 7.0)
    elseif nivel_exercicio == "A"
        (6.0, 12.0)
    end

    Carb_min = peso * Carb_fator_min
    Carb_max = peso * Carb_fator_max

    # Calorias consumidas por proteínas e carboidratos
    kcal_PC_min = (P_min * 4) + (Carb_min * 4)
    kcal_PC_max = (P_max * 4) + (Carb_max * 4)

    # Gorduras calculadas pelas calorias restantes
    G_min = (C_min - kcal_PC_max) / 9
    G_max = (C_max - kcal_PC_min) / 9

    # Evita valores negativos
    G_min = max(G_min, 0)
    G_max = max(G_max, 0)

    return (
        C_min, C_max,
        P_min, P_max,
        G_min, G_max,
        Carb_min, Carb_max,
        preferencias,
        pessoa.orcamento
    )
end