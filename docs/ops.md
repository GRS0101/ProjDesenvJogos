# Operações — Banco de Dados de Perfis de Usuário

Este documento descreve como configurar e operar o job de retenção, agendamento e verificação relacionados à feature `001-user-profiles-db`.

Resumo rápido
- Política padrão: "archive then purge" (arquivar após 1 ano, purgar após janela adicional configurável).
- Local dos artefatos:
  - Migration: `src/infrastructure/sqlite/migrations/create_visits_archive.sql`
  - Retention job (a implementar): `src/infrastructure/sqlite/retention_job.gd`
  - Checklist/CI: `.github/workflows/pre-test-check.yml`, `scripts/ci/pre_test_check.ps1`, `tools/coverage-checker.py`

Variáveis de configuração recomendadas
- `RETENTION_MODE` — `archive|anonymize|purge` (default: `archive`).
- `RETENTION_ARCHIVE_WINDOW_DAYS` — dias adicionais a reter o archive antes de purge (default: 365).
- `RETENTION_BATCH_SIZE` — número de linhas processadas por lote (default: 1000).
- `RETENTION_DRY_RUN` — quando `true` executa sem aplicar mudanças.
- `GODOT_PATH` — caminho absoluto para o executável Godot (definir em GitHub Secrets para CI).

Agendamento recomendado (padrão)
- Daily: `dry-run` (simulação) automática para validar sem alterações.
- Weekly: `archive` — move eventos com >1 ano para `visits_archive` em lotes.
- Monthly: `purge` — remove permanentemente arquivos arquivados com idade > (`1 ano + RETENTION_ARCHIVE_WINDOW_DAYS`).

Executar manualmente (exemplos)

PowerShell (dry-run):
```powershell
pwsh scripts/ci/pre_test_check.ps1; 
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/ci/pre_test_check.ps1 -SkipGodotCheck
# Executar job de retenção (exemplo):
pwsh -NoProfile -ExecutionPolicy Bypass -Command "& 'godot' --script src/infrastructure/sqlite/retention_job.gd -- --mode dry-run --batch-size 1000"
```

Exemplo (modo confirm/purge):
```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -Command "& 'godot' --script src/infrastructure/sqlite/retention_job.gd -- --mode purge --confirm"
```

Rollback e migração
- A migration `create_visits_archive.sql` apenas cria a tabela e índices. Para rollback manual, manter um script `down` que remove índices e tabela:

```sql
-- down migration (manual)
DROP INDEX IF EXISTS idx_visits_archive_timestamp;
DROP INDEX IF EXISTS idx_visits_archive_user_id;
DROP TABLE IF EXISTS visits_archive;
```

- Recomendação: testar migrations em DB temporário antes de executar em produção; manter backups e snapshots do arquivo SQLite antes de operações de purge.

Auditoria
- O job de retenção deve gravar em `logs/retention/` (ou tabela `retention_audit`) um registro JSON por execução com campos: `operation`, `affected_count`, `cutoff_timestamp`, `mode`, `started_at`, `completed_at`, `actor`.

CI / Secrets
- Defina `GODOT_PATH` em Secrets para permitir checagens Godot headless no workflow `.github/workflows/pre-test-check.yml`.
- Configure a geração de `coverage.xml` (gdUnit4 ou ferramenta escolhida) e garanta que o job envie o arquivo para `tools/coverage-checker.py`.

Observações operacionais
- Operações de purge devem ser manuais por padrão (exigir `--confirm`) e preferencialmente feitas durante janela de manutenção.
- Use índices em `visits(timestamp)` e `visits(user_id)` para reduzir bloqueios e acelerar operações de archive/purge.

Contato e responsabilidades
- Owner: Guilherme (repositorio GitHub: `https://github.com/GRS0101/ProjDesenvJogos.git`, branch `001-user-profiles-db`).
