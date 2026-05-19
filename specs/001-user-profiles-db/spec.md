# Feature Specification: Banco de Dados de Perfis de Usuário (user-profiles-db)

**Feature Branch**: `001-user-profiles-db`  
**Created**: 19 de maio de 2026  
**Status**: Draft  
**Input**: User description: "Preciso de um banco de dados para armazenar dados de usuários de um aplicativo/jogo; O banco de dados deve conter informações simples(iinerentes ao login dele no app) do usuário para que ele possa ser registrado; o banco de dados também deve registrar informações da rotina do usuário com base nos pontos do mapa do jogo que ele frequenta para traçar perfis de usuário; perfis de usuário são agruapados por similaridade em seus pontos frequentados além de horário em que os locais foram frequentados;"

## Clarifications

### Session 2026-05-19

- Q: Qual período de retenção de dados pessoais? → A: 1 ano para eventos de visita e dados derivados.
- Q: Qual método de autenticação preferido? → A: Suportar credenciais locais (email/username + senha) e SSO (híbrido).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Registro e Login (Priority: P1)

Usuário cria uma conta no aplicativo usando credenciais básicas e efetua login.

**Why this priority**: Permite acesso ao jogo e coleta inicial de dados para perfis.

**Independent Test**: Criar um novo usuário, verificar persistência dos dados de login e realizar login subsequente.

**Acceptance Scenarios**:

1. **Given** tela de registro, **When** usuário submete informações válidas, **Then** conta é criada e dados básicos são persistidos.
2. **Given** conta existente, **When** usuário faz login com credenciais válidas, **Then** sistema autentica e registra `last_login`.

---

### User Story 2 - Registro de Rotina (Priority: P2)

O sistema registra eventos de visitação a pontos do mapa (pontos de interesse) com timestamp.

**Why this priority**: Dados de rotina são necessários para traçar perfis de comportamento.

**Independent Test**: Gerar eventos de visita para um usuário e verificar que cada evento é armazenado com `point_id` e `timestamp`.

**Acceptance Scenarios**:

1. **Given** usuário visita um ponto no mapa, **When** o evento é gerado, **Then** é criado um registro de visita com `user_id`, `point_id`, `timestamp`.
2. **Given** múltiplas visitas, **When** consultadas por período, **Then** retornam eventos na ordem cronológica.

---

### User Story 3 - Geração e Agrupamento de Perfis (Priority: P3)

O sistema agrega visitas para gerar perfis de usuário e agrupa perfis por similaridade de pontos frequentados e horários.

**Why this priority**: Permite segmentação de usuários para análises e personalização.

**Independent Test**: Executar rotina de agregação em dados de visita e verificar que perfis são gerados e agrupamentos fazem sentido para casos de teste conhecidos.

**Acceptance Scenarios**:

1. **Given** histórico de visitas de vários usuários, **When** a rotina de agregação é executada, **Then** cada usuário recebe um perfil com lista de pontos frequentes e janelas de horário predominantes.
2. **Given** perfis gerados, **When** executado o algoritmo de agrupamento, **Then** usuários com padrão similar de pontos e horários ficam no mesmo grupo.

---

### Edge Cases

- O que acontece quando eventos de visita chegam fora de ordem ou com timestamp futuro? Deve haver validação e normalização.
- Como tratar usuários sem visitas ou com visitas muito esparsas? Devem receber perfis "padrão" ou permanecerem sem perfil.
- Falha parcial: eventos duplicados devem ser tratados idempotentemente.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Sistema MUST permitir criação de conta e armazenamento de informações de login mínimas (por exemplo: `user_id`, `email`/`username`, `password_hash`, `created_at`, `last_login`).
- **FR-002**: Sistema MUST registrar eventos de visita a pontos do mapa com pelo menos: `event_id`, `user_id`, `point_id`, `timestamp`, `metadata` opcional (ex.: duração, método de chegada).
- **FR-003**: Sistema MUST permitir consulta eficiente do histórico de visitas por `user_id` e por intervalo de tempo.
- **FR-004**: Sistema MUST agregar visitas para gerar um `user_profile` contendo: lista de `points_frequented` (com contagens), janelas de horário predominantes e métricas de atividade (ex.: visitas por semana).
- **FR-005**: Sistema MUST executar agrupamento (clustering) de `user_profile`s por similaridade de pontos frequentados e horários, criando `profile_group` identificáveis.
- **FR-006**: Sistema MUST registrar data e hora de criação/atualização de perfis e grupos para auditoria.
- **FR-007**: Sistema MUST suportar consentimento do usuário para coleta de rotina e permitir opt-out (ANOTAÇÃO: ver Assumptions / Clarifications).

*Exemplo de marcação de requisitos incertos:*

- **FR-008**: Políticas de retenção de dados devem ser definidas. Período padrão: 1 ano para eventos de visita e dados derivados; regras de arquivamento e anonimização aplicam-se após esse período.
- **FR-009**: Método de autenticação: suportar credenciais locais (email/username + senha) e SSO (provedores externos). A opção híbrida permite que usuários escolham o método preferido.

### Key Entities *(include if feature involves data)*

- **User**: representa o jogador; atributos principais: `user_id`, `username`/`email`, `password_hash`, `created_at`, `last_login`, `consent_flags`.
- **Point**: ponto do mapa/jogo que pode ser visitado; atributos: `point_id`, `name`, `coordinates` (referência), `category`.
- **VisitEvent**: evento de visita; atributos: `event_id`, `user_id`, `point_id`, `timestamp`, `duration`, `metadata`.
- **UserProfile**: agregação de visitas; atributos: `profile_id`, `user_id`, `points_frequented` (com contagens), `time_windows`, `last_aggregated_at`.
- **ProfileGroup**: grupo de perfis similares; atributos: `group_id`, `member_profile_ids`, `similarity_metrics`, `created_at`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% dos usuários conseguem completar o registro em menos de 2 minutos.
- **SC-002**: 99% dos eventos de visita gerados por clientes são persistidos com sucesso (sem perda) em condições normais.
- **SC-003**: Perfis gerados cobrem pelo menos 80% dos usuários que geraram >= 5 eventos de visita no período de 30 dias.
- **SC-004**: Agrupamentos produzem grupos interpretáveis em casos de teste controlados (validação qualitativa durante testes).

## Assumptions

 - Usuários consentem implicitamente para coleta de rotina a menos que optem por remover (opt-out), salvo requisitos legais contrários.
 - Autenticação suportada: local (email/username + senha) e SSO externo; o sistema deve armazenar `password_hash` quando aplicável e permitir integração futura com provedores.
 - O sistema inicial precisa apenas armazenar dados necessários para registro, visitas e geração de perfis; análises avançadas são fora do escopo.
 - Retenção de dados segue política padrão do produto — por padrão usaremos 1 ano para dados de eventos (ajustável após esclarecimento).
 - Integração com sistema de autenticação existente é possível no futuro, mas não obrigatória para v1.


---

**Notas**: As marcações [NEEDS CLARIFICATION] foram resolvidas: retenção definida como 1 ano e autenticação definida como local + SSO (híbrido).
