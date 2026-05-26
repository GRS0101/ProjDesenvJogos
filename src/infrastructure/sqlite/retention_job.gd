extends Node

# Retention job skeleton
# Usage (from CLI):
# godot --script src/infrastructure/sqlite/retention_job.gd -- --mode dry-run --batch-size 1000 --confirm

class_name RetentionJob

func _init():
    pass

func run(mode: String = "dry-run", batch_size: int = 1000, dry_run: bool = true, confirm: bool = false) -> Dictionary:
    # mode: one of 'dry-run', 'archive', 'anonymize', 'purge'
    # This is a non-destructive skeleton. Implement DB access via your SQLite addon.

    var summary = {
        "mode": mode,
        "batch_size": batch_size,
        "dry_run": dry_run,
        "processed": 0,
        "errors": []
    }

    # Determine cutoff timestamp (1 year ago)
    var now = OS.get_unix_time()
    var cutoff = now - 365 * 24 * 3600

    # Pseudocode for processing loop:
    # 1. SELECT id FROM visits WHERE timestamp < cutoff LIMIT batch_size
    # 2. If mode == 'archive': INSERT INTO visits_archive (...) SELECT ...; DELETE FROM visits WHERE id IN (...)
    # 3. If mode == 'anonymize': UPDATE visits SET user_id=NULL, metadata=NULL WHERE id IN (...)
    # 4. If mode == 'purge': DELETE FROM visits WHERE id IN (...)
    # 5. Commit per batch and record audit entry

    # For now, return a dry-run summary object for tests to assert shape
    summary.processed = 0
    return summary

func _run_from_cli(args: Array):
    var mode = "dry-run"
    var batch_size = 1000
    var dry_run = true
    var confirm = false
    for i in range(args.size()):
        var a = args[i]
        if a == "--mode" and i+1 < args.size():
            mode = args[i+1]
        elif a == "--batch-size" and i+1 < args.size():
            batch_size = int(args[i+1])
        elif a == "--confirm":
            confirm = true
            dry_run = false
        elif a == "--dry-run":
            dry_run = true

    var res = run(mode, batch_size, dry_run, confirm)
    print(res)

if Engine.has_singleton("CLI"):
    # No-op in editor; CLI execution will use _run_from_cli
    pass
