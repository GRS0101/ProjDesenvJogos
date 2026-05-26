# tests/integration/test_retention_job.gd
extends "res://addons/gdunit4/test.gd"

func test_retention_job_dry_run_exists_and_returns_summary():
    var job_path = "res://src/infrastructure/sqlite/retention_job.gd"
    assert_true(FileAccess.file_exists(job_path), "Retention job file must exist: %s" % job_path)

    # Load the script and call run() in dry-run mode
    var script = load(job_path)
    assert_true(script != null, "Could not load retention job script")

    var inst = script.new()
    var summary = inst.run("dry-run", 10, true, false)
    assert_true(summary.has("mode"), "Summary must include 'mode'")
    assert_eq(summary["mode"], "dry-run")
    assert_true(summary.has("processed"))

    # Expect processed to be numeric (0 in skeleton)
    assert_true(typeof(summary["processed"]) == TYPE_INT)
