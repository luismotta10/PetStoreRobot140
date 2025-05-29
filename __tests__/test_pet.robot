*** Settings ***
# Bibliotecas e Configurações
Library    RequestsLibrary

*** Variables ***
# Objetos, Atributos e Variables
${url}    https://petstore.swagger.io/v2/pet         

${id}    702190001                            # $ sinaliza uma variável simples
${name}    Snoopy                             
&{category}    id=1    name=cachorro          # & sinaliza lista com campos determinados. Ex: id e name - seria {} 
@{photoUrls}                                  # @ sinaliza uma lista com vários registros - seria []
&{tag}    id=1    name=vacinado
@{tags}    ${tag}                             # fez uma lista de outra lista
${status}    available

*** Test Cases ***
# Descritivo de Negócio + Passos de Automação

Post pet
    # montar a mensagem / body
    ${body}    Create Dictionary    id=${id}    category=${category}    name=${name}
    ...                             photoUrls=${photoUrls}    tags=${tags}    status=${status}   
        
    # Executar                                            # o verify=false é necessário em caso de ambiente corporativo / ssl bloqueado
    ${response}    POST    url=${url}    json=${body}    verify=${False} 

    # Validar
    ${response_body}    Set Variable    ${response.json()}  # recebe o conteudo da outra variável
    Log To Console    ${response_body}        # imprimir o retorno da API no terminal / console

    Status Should Be    200
    Should Be Equal    ${response_body}[id]               ${{int($id)}}
    Should Be Equal    ${response_body}[name]             ${name}
    Should Be Equal    ${response_body}[tags][0][id]      ${{int(${tag}[id])}}
    Should Be Equal    ${response_body}[tags][0][name]    ${tag}[name]    
    Should Be Equal    ${response_body}[status]           ${status}    

Get pet
    # executa
    ${response}    GET    ${{$url + '/' + $id}}    verify=${False}      
    

    # valida
    ${response_body}    Set Variable    ${response.json()}
    Log To Console    ${response_body}

    Status Should Be    200
    Should Be Equal    ${response_body}[id]    ${{int($id)}}
    Should Be Equal    ${response_body}[name]    ${name}
                                                       # ${category}[id]
                                                       # ${{int(${category}[id])}}
    Should Be Equal    ${response_body}[category][id]    ${{int(${category}[id])}}
    Should Be Equal    ${response_body}[category][name]    ${category}[name]


Put pet
    # montar a mensagem / body com a mudança
    ${body}    Evaluate    json.loads(open('./fixtures/json/pet2.json').read())    # json carrega abrindo o arquivo no caminho e depois ler

    # executar
    ${response}    PUT    url=${url}    json=${body}    verify=${False}

    # valida
    ${response_body}    Set Variable    ${response.json()}

    Status Should Be    200
    Should Be Equal    ${response_body}[id]                ${{int($id)}}
    Should Be Equal    ${response_body}[category][id]      ${{int(${category}[id])}}
    Should Be Equal    ${response_body}[category][name]    ${category}[name]
    Should Be Equal    ${response_body}[name]              ${name}                                             
    Should Be Equal    ${response_body}[tags][0][id]       ${{int(${tag}[id])}}
    Should Be Equal    ${response_body}[tags][0][name]     ${tag}[name]    
    Should Be Equal    ${response_body}[status]            sold        # valor fixo     
    Should Be Equal    ${response_body}[status]            ${body}[status]    # compara o valor que está no arquivo


Delete pet
    #executa
    ${response}    DELETE    ${{$url + '/' + $id}}    verify=${False}

    # valida
    ${response_body}    Set Variable    ${response.json()} 
    Log To Console    ${response_body}        

    Status Should Be    200
    Should Be Equal    ${response_body}[code]        ${{int(200)}}
    Should Be Equal    ${response_body}[type]        unknown
    Should Be Equal    ${response_body}[message]     ${id}




*** Keywords ***
# Descritivo de Negócio (se estruturar separadamente)
# DSL = Domain Specific Language = Linguagem Especifica de Dominio