Primeiros passos do projeto Flow

Contexto rapido do escopo
- Ingestao de telemetria em tempo real com backpressure (Broadway).
- Processamento assincrono e persistente de alertas (Oban + Postgres).
- Atualizacao em tempo real no dashboard (Phoenix LiveView + PubSub).
- Entidades principais: Vehicle, TelemetryEvent, Alert.
- Pipeline: API -> Broadway (batch) -> Postgres -> Oban -> PubSub -> LiveView.
- Qualidade: testes de contexto, typespecs e Credo.

Primeiros passos (ordem inicial para comecar)
1) Preparar ambiente de desenvolvimento
- Instalar Elixir, Erlang e Phoenix.
- Definir versoes alvo no README (ex: Elixir 1.15+, Erlang/OTP 26+).

2) Criar o projeto Phoenix base
- Gerar app sem mailer e com Postgres.
- Validar que o app sobe localmente (mix phx.server).

3) Infra de banco e containers
- Criar Dockerfile e docker-compose (app + postgres).
- Garantir configuracoes de banco para dev/test.

4) Fundacao de dominio (Fase 1 do spec)
- Criar contexto Fleet.
- Criar schemas Vehicle, TelemetryEvent, Alert.
- Criar migrations com indices (vehicle_id, timestamp).

5) Setup de qualidade
- Adicionar Credo.
- Criar base de testes para o contexto Fleet.
- Adicionar typespecs nas funcoes publicas dos contextos.

Resultados esperados ao final desses passos
- App Phoenix rodando com Postgres.
- Migrations aplicadas e schemas prontos.
- Bases de testes e lint configuradas.

Proximos passos depois disso
- Implementar pipeline Broadway e API /api/telemetry.
- Adicionar Oban e worker de alertas.
- Iniciar LiveView de dashboard e PubSub.
