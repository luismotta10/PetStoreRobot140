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
${status}    

*** Test Cases ***
# Descritivo de Negócio + Passos de Automação

Post pet
    # montar a mensagem / body
    ${body}    Create Dictionary    id=${id}    category=${category}    name=${name}
    ...                             photoUrls=${photoUrls}    tags=${tags}    status=${status}   
        
    # Executar
    ${response}    POST    url=${url}    json=${body}    verify=${False} # o verify=false é necessário em caso de ambiente corporativo / ssl bloqueado

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
                                                        # ${{int($category[id])}}
    Should Be Equal    ${response_body}[category][id]    ${{int($category[id])}}
    Should Be Equal    ${response_body}[category][name]    ${category}[name]




*** Keywords ***
# Descritivo de Negócio (se estruturar separadamente)
# DSL = Domain Specific Language = Linguagem Especifica de Dominio