Flow: Engine de Telemetria e Monitoramento de Frotas
1. Visão Geral do Projeto

O Flow é um sistema de alta performance para ingestão, processamento e visualização de dados de telemetria veicular em tempo real. O objetivo é simular um ambiente de logística de missão crítica, capaz de lidar com picos de tráfego (backpressure), garantir a persistência de dados e gerar alertas de infrações (ex: excesso de velocidade) de forma assíncrona.

Este projeto serve como Prova de Conceito (PoC) para demonstrar competência em Sistemas Distribuídos, Elixir/OTP e arquitetura resiliente.
2. Decisões Arquiteturais e Stack Tecnológico
2.1 Linguagem: Elixir & Erlang VM (BEAM)

    Decisão: Utilizar Elixir em vez de Java ou PHP.

    Por que: A natureza do projeto (milhares de conexões simultâneas e processamento de streams) exige o modelo de atores da BEAM. O Elixir oferece tolerância a falhas (Supervisors) e latência previsível, essenciais para sistemas de telemetria.

2.2 Ingestão de Dados: Broadway

    Decisão: Utilizar a biblioteca Broadway para o pipeline de ingestão.

    Por que: Precisamos de Backpressure (Controle de Fluxo). Se 10.000 caminhões enviarem dados ao mesmo tempo, não podemos derrubar o banco de dados. O Broadway permite agrupar mensagens em batches (lotes) e processá-las de forma controlada.

2.3 Processamento Assíncrono: Oban

    Decisão: Utilizar Oban (baseado em PostgreSQL) para background jobs.

    Por que: Diferente de filas em memória que perdem dados se o servidor reiniciar, o Oban garante a persistência dos jobs. Isso é crucial para garantir que um alerta de segurança (ex: "Veículo roubado") seja processado mesmo em caso de falha momentânea da aplicação.

2.4 Interface em Tempo Real: Phoenix LiveView

    Decisão: Renderização server-side com LiveView via WebSockets.

    Por que: Elimina a complexidade de manter uma SPA separada (React) e uma API RESTful apenas para o dashboard. O LiveView permite atualizações instantâneas de status dos veículos com menor overhead de desenvolvimento e latência mínima.

2.5 Banco de Dados: PostgreSQL

    Decisão: Banco relacional robusto.

    Por que: Necessidade de integridade referencial entre Veículos e Eventos. O PostgreSQL lida excelentemente com cargas de escrita em lote (via Broadway) e servirá como fila para o Oban.

3. Escopo Funcional e Fluxo de Dados
3.1 Entidades Principais

    Vehicle (Veículo):

        id: UUID

        license_plate: String (Placa)

        status: Enum (active, maintenance)

    TelemetryEvent (Evento de Telemetria):

        vehicle_id: FK

        latitude: Float

        longitude: Float

        speed: Float (km/h)

        timestamp: DateTime

        Obs: Esta tabela deve ser otimizada para escrita (TimescaleDB seria ideal no futuro, mas Postgres puro serve para o MVP).

    Alert (Alerta):

        vehicle_id: FK

        type: String (ex: "SPEED_LIMIT_EXCEEDED")

        description: String

        resolved: Boolean

3.2 O Pipeline de Dados (The "Happy Path")

    Simulação: Um script externo envia requisições HTTP POST para /api/telemetry contendo JSONs de múltiplos veículos.

    Ingestão (Broadway):

        Recebe o payload.

        Agrupa (Batching) de 50 em 50 eventos ou a cada 500ms.

        Insere no PostgreSQL em uma única transação (repo.insert_all).

    Análise de Regras (Business Logic):

        Durante o processamento no Broadway, se speed > 80.0:

        Enfileira um job no Oban (GenerateAlertWorker).

    Notificação (PubSub):

        Ao inserir um evento ou gerar um alerta, o sistema publica uma mensagem no Phoenix.PubSub.

    Visualização (LiveView):

        O Dashboard assina o tópico do PubSub.

        Recebe a mensagem e atualiza o mapa/lista na tela do usuário instantaneamente.

4. Guia de Implementação (Passo a Passo para a IA)

Instrução para a IA: Ao implementar, siga estritamente esta ordem para garantir testabilidade.
Fase 1: Fundação (Setup)

    Criar projeto Phoenix sem mailer, com Postgres.

    Configurar Docker e Docker Compose (App + DB).

    Criar Contexto Fleet e Schemas (Vehicle, TelemetryEvent, Alert).

    Criar Migrations com índices adequados (indexar vehicle_id e timestamp).

Fase 2: O Motor de Ingestão (Broadway)

    Adicionar dependência broadway.

    Criar módulo Flow.Telemetry.Pipeline.

    Configurar producer dummy (inicialmente) ou integrar direto com um Controller Phoenix que empurra dados para o Broadway.

    Implementar handle_message (validação simples).

    Implementar handle_batch (inserção em massa no banco).

Fase 3: Regras de Negócio e Jobs (Oban)

    Adicionar dependência oban.

    Configurar filas do Oban (default, high_priority).

    Criar Worker Flow.Workers.AlertGenerator.

    Alterar o Pipeline do Broadway para disparar o worker quando a velocidade for excessiva.

Fase 4: Visualização (LiveView)

    Criar FlowWeb.DashboardLive.

    Layout básico: Tabela de últimas leituras e Lista de Alertas ativos.

    Implementar listeners do Phoenix.PubSub para atualizar a UI quando novos dados chegarem.

Fase 5: Simulação (Carga)

    Criar um script (pode ser em Elixir mesmo, na pasta priv/repo/seeds.exs ou um script separado .exs) que:

        Cria 10 veículos no banco.

        Entra em loop infinito enviando dados randômicos de GPS e velocidade para a API.

5. Requisitos Não Funcionais (Qualidade)

    Testes: Todo módulo de contexto deve ter testes unitários (ExUnit).

    Tipagem: Usar Typespecs (@spec) em funções públicas para clareza.

    Linter: Seguir o guia de estilo do Credo (adicionar como dependência).