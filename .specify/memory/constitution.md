## com relação ao estido de programação:
- usar Behavior-Driven Development
- usar Test-Driven Development
- usar princípios S.O.L.I.D
- usar Clean Architecture, dividindo em camadas, usando ports e adapters
- usar Domain-Driven Design
- usar Dependency Injection
- usar Inversion of Control
- usar Repository Pattern
- criar testes para os requisitos e regras de negócio, não para o código ;
- somente criar código após ter testes conforme descrito antes ;
- antes de executar os testes deve executar compilação e/ou análise estática dos módulos de teste e código ;
- sempre testar o código após cada alteração, refatoração, ou novo código ;
- antes de criar testes de integração, sempre criar testes unitários com 100% de cobertura de testes ;
- criar testes de funcionalidade sob a ótica do usuário, interagindo com a tela, operando as funcionalidades conforme um usuário, no caminho feliz, e em cada condição alternativa, como em mensagens de erro, alertas e exceptions.

## estratégias
- sempre entrevistar o usuário para entender suas necessidades e expectativas, documentar requisitos ao encontrar alguma lacuna de conhecimento ou algo não especificado ;
- sempre que for perguntar ao usuário faça somente uma pergunta de cada vez, sobre somente um assunto de cada vez ;
- após perguntar ao usuário aguarde a resposta, verifique se ainda existe alguma lacuna ou dúvida, e só então faça outra pergunta ;
- sempre registre suas perguntas e as respostas do usuário em um arquivo de decisões de projeto em /docs/decisions.md ;
- sempre escrever um plano passo-a-passo com checklist antes de implementar ou dar manutenção em qualquer funcionalidade ;
- identificar a oportunidade de criação de agentes especializados para executar tarefas repetitivas, perguntar ao usuário se ele deseja criar um agente especializado para executar tais tarefas e documentar no arquivo docs/agents.md ;
- sempre tente deduzir decisões em função do constitution e das especificações existentes, antes de perguntar ao usuário ;
- o planejamento deve ser documentado em um arquivo plan.md no diretório da funcionalidade, mas deve ser detalhado, considerando fases evolutivas, testes primeiro em função dos requisitos (não do código), codificação para atender aos testes, buscar 100% de cobertura, refatorar para interfaces e desacoplamento, depois testes de integração ;

## Testes: você deve sempre criar testes antes de implementar qualquer funcionalidade. Os testes devem se dividir em:
- primeiro criar o gherkin da funcionalidade, definindo o futuro usuário, o que ela vai fazer e o benefício esperado ;
- depois criar o cenário do caminho feliz, que é o comportamento básico da funcionalidade executado com sucesso ;
- depois cada cenário alternativo da funcionalidade, que é o comportamento da funcionalidade em caso de erro, ou interrupção (mensagens, popups, etc) ou exceção ;
- depois criar testes unitários do frontend, descrevendo os comportamentos do frontend de cada componente ;
- depois criar os testes de interface (frontend), descrevendo os comportamentos da interface em cada cenário ;
- depois criar testes unitários do backend, descrevendo os comportamentos do backend em cada componente ;
- depois criar os testes de integração do backend, descrevendo os comportamentos do backend de integração em cada cenário ;
- depois criar testes de integração frontend com backend ;
- ao criar testes tente não usar mocks automáticos, tente criar classes de mocks manualmente ;
- ao criar testes unitários, sempre use a técnica AAA (Arrange, Act, Assert) ;
- sempre configure os testes para que em seu arquivo de configuração busque atingir 100% de cobertura obrigatoriamente ;
- configure o vitest para apresentar sempre a cobertura de testes ;
- configure o playwright para apresentar sempre a cobertura de testes ;
- crie um diretório de tests em paralelo de src, não salve os testes dentro de src ;
- crie um script para testar o código fonte através de npm run check, que deve compilar todo o código ;


## arquitetura: preferencialmente usar
- a linguagem typescript, mas pode usar outra linguagem se justificar ;
- postgresql, mas pode usar outro banco de dados se justificar ;
- ReactJs, mas pode usar outra biblioteca se justificar ;
- vitest, mas pode usar outro framework de testes se justificar ;
- playwright, mas pode usar outro framework de testes se justificar ;

## funcionamento da IA
- sempre que for perguntar ao usuário faça somente uma pergunta de cada vez, sobre somente um assunto de cada vez ;
- antes de planejar a parte técnica, devemos pensar nas necessidades do cliente, na visão do produto, e na especificação das funcionalidades, para depois planejar (Object Oriented Design) a arquitetura e o design do sistema, e por fim a implementação ;
- a criação de código sempre deve ser seguida da execução de npm run check e npm run test:coverage, e só então seguir para a próxima atividade de implementação ;

## as Especificações (análise):
- devem registrar o escopo sob a ótica do usuário
- registrar a visão do produto
- devem registrar o valor para o usuário (Feature do Gherkin)
- devem registrar o os vários critérios de aceitação

## o Planejamento técnico (plan.md)
- deve definir o passo-a-passo de implementação da funcionalidade
- deve definir fases evolutivas
- deve definir incrementos de comportamentos
- deve definir pontos de checagem de funcionamento
- deve definir atividades de implementação
- deve definir os resultados esperados de cada atividade de implementação
- tudo no planejamento deve ser planejado passo-a-passo (chain of thought)
- cada ponto do planejamento deve ter um checklist de execução
- os testes devem ser feitos sempre antes de qualquer implementação
- os testes devem ser executados antes de dar como encerrado um incremento ou fase
- deve definir a base de dados, os modelos, as entidades, os repositórios, 
- deve definir os serviços, os controladores, as rotas
- após executar qualquer atividade do planejamento, precisa marcar (check) no planejamento e/ou no roadmap