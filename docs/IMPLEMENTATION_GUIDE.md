# Guia de Implementação — User Profiles DB (Godot)

Este documento descreve, passo a passo, como integrar e operar os artefatos criados neste repositório dentro de um projeto Godot 4.x.

## Resumo
- Código Godot: `src/` (entities, repositories, services, infrastructure)
- Migrations: `src/infrastructure/sqlite/migrations/`
- Job de retenção (GDScript): `src/infrastructure/sqlite/retention_job.gd`
- Utilitário Python de retenção: `tools/retention_job.py`
- Gerador de carga: `tests/perf/load_generator.py`
- Testes de integração (Python): `tests/integration/test_retention_job_py.py`

## Pré-requisitos
- Godot 4.2+ instalado
- Python 3.8+ (para ferramentas e testes Python)
- SQLite CLI (opcional, para aplicar migrations manualmente)
- (Opcional) `gdUnit4` para rodar testes GDScript

## 1. Abrir / criar projeto Godot
1. Abra o Godot e selecione a pasta deste repositório como projeto (arquivo `project.godot` já incluído).
2. Em `Project → Project Settings → Autoload` registre `src/presentation/autoload/app_container.gd` com o nome `AppContainer`.

## 2. Adicionar e ativar addons (SQLite, gdUnit4)
1. Coloque o addon SQLite em `addons/` (ex.: `addons/sqlite/`).
2. Ative o plugin em `Project → Project Settings → Plugins`.
3. Se for usar `gdUnit4`, coloque-o em `addons/gdunit4/` e ative.

## 3. Criar banco e aplicar migrations
1. Criar pasta `data/` na raiz do projeto:

```powershell
mkdir data
```

2. Aplicar a migration `create_visits_archive.sql` com o CLI sqlite3:

```bash
sqlite3 data/user_data.db < src/infrastructure/sqlite/migrations/create_visits_archive.sql
```

3. (Opcional) criar a tabela `visits` se não existir (crie um arquivo SQL em migrations e aplique similarmente).

## 4. Popular dados para testes
Usar o gerador de carga Python incluído:

```bash
python tests/perf/load_generator.py --db data/user_data.db --count 10000 --batch 500 --out perf_summary.json
```

Saída: `perf_summary.json` com percentis de latência.

## 5. Executar o job de retenção

Opção A — via Godot (headless):

```powershell
# Defina a variável de ambiente GODOT_PATH para o executável do Godot
# Exemplo (PowerShell):
# $env:GODOT_PATH = "C:\Path\To\Godot.exe"

& $env:GODOT_PATH --headless --script src/infrastructure/sqlite/retention_job.gd -- --mode archive --confirm --db data/user_data.db
```

Observação: `retention_job.gd` detecta adaptadores SQLite comuns (`Engine` singleton, `SQLite`, ou formas encontradas em `res://addons/*sqlite*`).

Opção B — utilitário Python (rápido para testes locais):

```bash
python tools/retention_job.py --db data/user_data.db --mode archive --cutoff-days 365 --batch 100
```

## 6. Testes

6.1 Testes Python (integração)

```bash
python -m pytest tests/integration/test_retention_job_py.py
```

6.2 Testes GDScript (gdUnit4) — headless

```powershell
# Defina GODOT_PATH e rode o runner do gdUnit4
& $env:GODOT_PATH --headless --script addons/gdunit4/run_tests.gd -- --suite unit
```

## 7. CI/CD (recomendações)
- Adicionar workflow que execute `scripts/ci/pre_test_check.ps1` antes de rodar testes.
- Gerar `coverage.xml` para os testes unitários e aplicar `tools/coverage-checker.py` para validar políticas de cobertura.
- Definir segredo `GODOT_PATH` no GitHub Actions se quiser rodar Godot headless no CI.

## 8. Adaptação a um addon SQLite específico
Se o addon tiver API própria, informe o nome da pasta em `addons/` e os métodos públicos (ex.: `open(path)`, `exec(sql)`, `query(sql)`); o `retention_job.gd` pode ser adaptado para usar diretamente essas chamadas.

## 9. Agendamento e operação
- Para agendar execução em produção, use um agendador do SO (Task Scheduler no Windows, cron em Linux) que invoque o Godot em modo headless com o script do job, ou execute o utilitário Python conforme necessidade.

## 10. Backup e rollback
- Faça backups regulares de `data/user_data.db` antes de rodar `purge` em produção.
- Tenha um down-migration ou playbook de rollback para `visits_archive`/`visits` antes de operações destrutivas.

## 11. Auditoria e compliance
- O job grava entradas em `retention_audit`. Confirme com a tarefa T048 a lista de campos PII que devem ser anonimizados e a política de retroatividade.

## 12. Troubleshooting rápido
- Se `retention_job.gd` reportar que não encontrou adapter SQLite, use o utilitário Python para testar a lógica localmente.
- Se os testes GDScript não rodarem, verifique `addons/gdunit4` e `GODOT_PATH`.
- Logs Godot: ver console do Godot ou usar a opção `--verbose` na execução headless.

## 13. Próximos passos recomendados
1. Revisar e aprovar a issue T048 (compliance).
2. Adaptar `retention_job.gd` a um addon SQLite real do projeto (se houver).
3. Completar testes GDScript que cobrem `VisitEvent`/`User`/`ConsentPolicy`.
4. Criar workflow GitHub Actions que execute `pre_test_check`, testes e verificação de cobertura.

---
Arquivo gerado automaticamente pelo assistente de implementação. Se desejar, atualizo com exemplos específicos para o addon SQLite que você usa (informe o nome da pasta em `addons/`).
