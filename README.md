# Otimização de Dietas usando Programação Inteira 


- [1. Descrição do Projeto](#1-Descrição-do-Projeto)
- [2. Objetivos](#2-Objetivos)
- [3. Coleta de Dados](#3-Coleta-de-Dados)
- [4. Input do Programa](#Input-do-Programa)
- [5. Definição Função Objetivo e Restrições](#4-Definição-Função-Objetivo-e-Restrições)
- [6. Output do Programa](#5-Output-do-Programa)
- [7. Técnicas e Tecnologias Utilizadas](#6-Técnicas-e-Tecnologias-Utilizadas)
- [8. Equipe](#7-Equipe)

## 1. Descrição do Projeto 
Este é um projeto acadêmico com a finalidade de estudo e aplicação de técnicas de **Programação Inteira**.

O foco central é o desenvolvimento de um programa capaz de, a partir dos dados orçamentários, das informações biológicas, das preferências alimentares e dos objetivos pessoais do usuário, construir uma dieta envolvendo café da manhã, almoço e jantar para um dia da tal forma que maximize as preferências do usuário ao mesmo tempo que atenda ao orçamento disponível e à taxa de macronutrientes necessários para respeitar as características fisiológicas desse usuário.

## 2. Objetivos

O objetivo do projeto é desenvolver um programa que receba as informações do usuário, calcule as necessidades nutricionais, considere as preferências alimentares fornecidas, respeite o orçamento máximo definido e gere uma dieta viável. 

## 3. Input do Programa
Para construção do banco de dados o usuário deve fornecer os seguintes dados: 

### Dados Pessoais 
- ``Sexo: Feminino ou Masculino``
- ``Idade, em anos``
- ``Peso Corporal, em quilogramas ``
- ``Altura, em centímetros``
- ``Nível de atividade física: Sedentário, Levemente ativo, Moderadamente ativo, Altamente ativo``
- ``Objetivo nutricional: Emagrecimento, Manutenção, Ganho de massa muscular ``
- ``Orçamento disponível``

### Dados referentes aos alimentos disponíveis 
  Para formulação da dieta foram selecionados os seguintes alimentos a serem escolhidos
  | Refeição       | Macronutriente | Opções Disponíveis                                      |
|----------------|----------------|---------------------------------------------------------|
| **Café da Manhã** | Proteína       | Ovo, iogurte, queijo                                    |
|                | Carboidrato    | Pão, banana, tapioca                                   |
|                | Gordura        | Abacate, manteiga, bacon                               |
| **Almoço/Janta** | Proteína       | Tilápia, peito de frango, acém bovino, ovo             |
|                | Carboidrato    | Arroz branco, macarrão, batata cozida, mandioca       |
|                | Gordura        | Azeitona, castanha de caju, bacon, batata frita       |

A partir das opções citadas acima, o usuário fornece uma nota de 0 a 5 para cada alimento, expressando sua afinidade e preferência a cada opção. Cada nota fornecida recebe um peso diferente para valorização dos alimentos mais apreciados. 


## 4. Construção dos dados para problema de otimização 


## 5. Definição Função Objetivo e Restrições
Para modelagem do problema analisado foram definidas variáveis de forma que para cada alimento analisado, foram definidas as seguintes variáveis: 

**Variável Binária**

$$
y_{it} =
\begin{cases}
1, & \text{se o alimento } i \text{ for consumido na refeição } t,\\
0, & \text{caso contrário.}
\end{cases}
$$

**Quantidade consumida**

  $$
q_{it} \geq 0
$$

onde q_{it}  representa a quantidade, em gramas, do alimento \(i\) consumida na refeição \(t\).

**Conjuntos**

- \(I\): conjunto dos alimentos disponíveis;
- \(T\): conjunto das refeições disponíveis.

### **Função Objetivo** 

A função objetivo é definida de modo a priorizar as preferências do usuário: 
$$
\sum_{i \in I} w_i y_{it}
$$
sujeita as seguintes restrições: 

#### Restrição Calórica

$$
Cal_{min} \leq \sum_{t} \sum_{i} k_i q_{it} \leq Cal_{max}
$$

*   \(Cal_{min}\) e \(Cal_{max}\): ingestão calórica mínima e máxima diária;
*   \(k_i\): quantidade de calorias por grama do alimento \(i\).

#### Restrição Proteíca

$$
P_{min} \leq \sum_{t} \sum_{i} p_i q_{it} \leq P_{max}
$$

*   \(P_{min}\) e \(P_{max}\): ingestão mínima e máxima de proteínas;
*   \(p_i\): quantidade de proteínas por grama do alimento \(i\).
*   
#### Restrição Glicídica
$$
C_{min} \leq \sum_{t} \sum_{i} c_i q_{it} \leq C_{max}
$$

*   \(C_{min}\) e \(C_{max}\): ingestão mínima e máxima de carboidratos;
*   \(c_i\): quantidade de carboidratos por grama do alimento \(i\).
  
#### Restrição Hipogordurosa
$$
G_{min} \leq \sum_{t} \sum_{i} g_i q_{it} \leq G_{max}
$$

*   \(G_{min}\) e \(G_{max}\): ingestão mínima e máxima de gorduras;
*   \(g_i\): quantidade de gorduras por grama do alimento \(i\).
  
#### Restrição Orçamentária
Também foi adicionada uma restrição para respeitar o orçamento fornecido pelo usuário:

$$
\sum_{t} \sum_{i} v_i q_{it} \leq B
$$

*   \(v_i\): custo por grama do alimento \(i\);
*   \(B\): orçamento disponível para a dieta.

#### Restrição de Seleção 

$$
L_i y_{it} \leq q_{it} \leq U_i y_{it}, \quad \forall i, t
$$

#### Restrição de Coerência Alimentar 
$$
y_{bacon} \leq y_{ovo}
$$

$$
y_{pão} + y_{tapioca} \leq 1
$$

$$
y_{batata} + y_{batata\ frita} \leq 1
$$

## 6. Output do Programa

Como saída do programa é fornecido uma tabela com os alimentos que devem ser consumidos em cada uma das refeições obtidas. Além disso, é fornecida uma tabela com o valor de macronutrientes consumidos durante o dia, a quantidade de calorias em kcal, além do custo bruto para confecção das refeições. 

## 7. Técnicas e Tecnologias Utilizadas
- ``Julia``
- ``HIGHS``
- ``JUMP``
- ``Overleaf``
## 8. Equipe
Este projeto foi desenvolvido por:

| NOME  | 
| :--- |
| Leticia Palomero Rodrigues | 
| Gabriel Augusto Rebouças Gomes | 
| Ana Luiza Freitas Palandi Barbosa|


