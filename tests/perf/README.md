Perf test tools
================

Este diretório contém ferramentas simples para gerar carga de escrita em SQLite e medir latências.

Exemplo de uso:

```bash
python tests/perf/load_generator.py --db perf_test.db --count 10000 --batch 500 --out perf_summary.json
```

O script cria uma tabela `visits` se necessário e insere `--count` eventos, com commits a cada `--batch` inserções.
O resultado JSON inclui percentis de latência (ms) que podem ser usados para validar os critérios de desempenho.
