#!/usr/bin/env python3
"""
Simple SQLite load generator for VisitEvent inserts and basic latency reporting.

Usage:
  python tests/perf/load_generator.py --db perf_test.db --count 10000 --batch 500

Outputs a JSON summary with count and latency percentiles (ms).
"""
import argparse
import sqlite3
import time
import random
import datetime
import json
import os
import statistics


def create_schema(conn):
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS visits (
        event_id TEXT PRIMARY KEY,
        user_id TEXT,
        point_id TEXT,
        timestamp DATETIME,
        duration_seconds INTEGER,
        accuracy_meters REAL,
        session_id TEXT,
        metadata TEXT
    )
    """)
    conn.commit()


def generate_row(i):
    now = datetime.datetime.utcnow()
    event_id = f"evt-{int(time.time())}-{i}-{random.getrandbits(24)}"
    user_id = f"user-{random.randint(1,1000)}"
    point_id = f"pt-{random.randint(1,500)}"
    timestamp = (now - datetime.timedelta(seconds=random.randint(0, 60 * 60 * 24 * 365))).isoformat()
    duration_seconds = random.randint(0, 300)
    accuracy_meters = round(random.uniform(5.0, 50.0), 2)
    session_id = f"sess-{random.randint(1,100000)}"
    metadata = json.dumps({"source":"perf_gen"})
    return (event_id, user_id, point_id, timestamp, duration_seconds, accuracy_meters, session_id, metadata)


def run_insert(conn, total, batch_size):
    latencies = []
    cur = conn.cursor()
    inserted = 0
    start_total = time.perf_counter()
    for i in range(total):
        row = generate_row(i)
        t0 = time.perf_counter()
        cur.execute("""
        INSERT OR REPLACE INTO visits (event_id,user_id,point_id,timestamp,duration_seconds,accuracy_meters,session_id,metadata)
        VALUES (?,?,?,?,?,?,?,?)
        """, row)
        inserted += 1
        latencies.append((time.perf_counter() - t0) * 1000.0)
        if batch_size > 0 and (i + 1) % batch_size == 0:
            conn.commit()
    conn.commit()
    total_ms = (time.perf_counter() - start_total) * 1000.0
    return inserted, latencies, total_ms


def percentile(vals, p):
    if not vals:
        return None
    vals_sorted = sorted(vals)
    k = (len(vals_sorted) - 1) * (p / 100.0)
    f = int(k)
    c = min(f + 1, len(vals_sorted) - 1)
    if f == c:
        return vals_sorted[int(k)]
    d0 = vals_sorted[f] * (c - k)
    d1 = vals_sorted[c] * (k - f)
    return d0 + d1


def main():
    parser = argparse.ArgumentParser(description="SQLite VisitEvent load generator and latency reporter")
    parser.add_argument("--db", default="perf_test.db", help="SQLite DB path")
    parser.add_argument("--count", type=int, default=1000, help="Number of rows to insert")
    parser.add_argument("--batch", type=int, default=100, help="Commit batch size (0=single transaction per insert)")
    parser.add_argument("--out", help="Optional JSON output file")
    args = parser.parse_args()

    db_path = args.db
    os.makedirs(os.path.dirname(db_path), exist_ok=True) if os.path.dirname(db_path) else None
    conn = sqlite3.connect(db_path, isolation_level=None)
    create_schema(conn)

    inserted, latencies, total_ms = run_insert(conn, args.count, args.batch)

    summary = {
        "db": db_path,
        "count": inserted,
        "total_ms": total_ms,
        "avg_ms": statistics.mean(latencies) if latencies else None,
        "p50_ms": percentile(latencies, 50),
        "p90_ms": percentile(latencies, 90),
        "p95_ms": percentile(latencies, 95),
        "p99_ms": percentile(latencies, 99),
    }

    print(json.dumps(summary, indent=2))
    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            json.dump(summary, f)


if __name__ == "__main__":
    main()
