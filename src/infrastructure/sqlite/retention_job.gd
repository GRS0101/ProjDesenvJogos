extends Node

# Retention job implementation (best-effort)
# Usage (from CLI):
# godot --script src/infrastructure/sqlite/retention_job.gd -- --mode dry-run --batch-size 1000 --confirm

class_name RetentionJob

const DEFAULT_DB_PATH := "data/user_data.db"

func _init():
    pass

func _now_unix() -> int:
    return OS.get_unix_time()

func _ensure_audit_table(db) -> void:
    # Create retention_audit table if not exists
    var sql = """
    CREATE TABLE IF NOT EXISTS retention_audit (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      operation TEXT,
      affected_count INTEGER,
      cutoff_timestamp INTEGER,
      mode TEXT,
      started_at INTEGER,
      completed_at INTEGER,
      actor TEXT,
      details TEXT
    );
    """
    db.exec(sql)

func _query_ids(db, cutoff_ts: int, limit: int) -> Array:
    var q = "SELECT id FROM visits WHERE timestamp < %d LIMIT %d" % [cutoff_ts, limit]
    var rows = db.query(q)
    var ids = []
    for r in rows:
        if r.has("id"):
            ids.append(r["id"])
        elif typeof(r) == TYPE_ARRAY and r.size() > 0:
            ids.append(r[0])
    return ids

func _ids_csv(ids: Array) -> String:
    return ",".join([str(i) for i in ids])

func run(mode: String = "dry-run", batch_size: int = 1000, dry_run: bool = true, confirm: bool = false, db_path: String = "") -> Dictionary:
    var summary = {
        "mode": mode,
        "batch_size": batch_size,
        "dry_run": dry_run,
        "processed": 0,
        "errors": []
    }

    if db_path == "":
        db_path = DEFAULT_DB_PATH

    var has_sqlite = false
    var db = null
    # Try common SQLite wrappers
    if Engine.has_singleton("SQLite"):
        db = Engine.get_singleton("SQLite")
        has_sqlite = true
    elif typeof(SQLite) != TYPE_NIL:
        db = SQLite.new()
        has_sqlite = true

    if not has_sqlite:
        # SQLite addon not present - perform safe dry-run and return
        summary.errors.append("SQLite adapter not found; dry-run simulation only")
        return summary

    # Attempt to open DB
    var opened = false
    if db.has_method("open"):
        opened = db.open(db_path)
    elif db.has_method("open_db"):
        opened = db.open_db(db_path)
    else:
        # unknown API - try generic constructor
        opened = true

    if not opened:
        summary.errors.append("Could not open DB at %s" % db_path)
        return summary

    # Ensure audit table exists
    if db.has_method("exec"):
        _ensure_audit_table(db)

    var cutoff = _now_unix() - 365 * 24 * 3600
    var total_processed = 0
    var start_ts = _now_unix()

    while true:
        var ids = _query_ids(db, cutoff, batch_size)
        if ids.empty():
            break

        # Build CSV for SQL IN clause
        var csv = _ids_csv(ids)

        if dry_run:
            # Just count
            total_processed += ids.size()
            # do not modify DB
        else:
            # perform action inside transaction
            if db.has_method("exec"):
                db.exec("BEGIN TRANSACTION;")
                if mode == "archive":
                    # Insert into visits_archive then delete
                    var insert_sql = "INSERT INTO visits_archive (event_id, user_id, point_id, timestamp, duration_seconds, accuracy_meters, session_id, metadata) SELECT event_id, user_id, point_id, timestamp, duration_seconds, accuracy_meters, session_id, metadata FROM visits WHERE id IN (%s);" % csv
                    db.exec(insert_sql)
                    db.exec("DELETE FROM visits WHERE id IN (%s);" % csv)
                elif mode == "anonymize":
                    db.exec("UPDATE visits SET user_id=NULL, metadata=NULL WHERE id IN (%s);" % csv)
                elif mode == "purge":
                    db.exec("DELETE FROM visits WHERE id IN (%s);" % csv)
                db.exec("COMMIT;")
                total_processed += ids.size()
            else:
                summary.errors.append("DB adapter lacks exec method; cannot modify DB")
                break

        # small pause to avoid hogging
        OS.delay_msec(10)

    var end_ts = _now_unix()
    summary.processed = total_processed

    # Insert audit row
    if db.has_method("exec"):
        var audit_sql = "INSERT INTO retention_audit (operation, affected_count, cutoff_timestamp, mode, started_at, completed_at, actor, details) VALUES ('%s', %d, %d, '%s', %d, %d, '%s', '%s');" % [mode, total_processed, cutoff, mode, start_ts, end_ts, 'system', '']
        db.exec(audit_sql)

    return summary

func _run_from_cli(args: Array):
    var mode = "dry-run"
    var batch_size = 1000
    var dry_run = true
    var confirm = false
    var db_path = ""
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
        elif a == "--db" and i+1 < args.size():
            db_path = args[i+1]

    var res = run(mode, batch_size, dry_run, confirm, db_path)
    print(res)

if Engine.has_singleton("CLI"):
    # If executed via CLI, parse args
    var cli_args = []
    if OS.has_method("get_cmdline_args"):
        cli_args = OS.get_cmdline_args()
    _run_from_cli(cli_args)
