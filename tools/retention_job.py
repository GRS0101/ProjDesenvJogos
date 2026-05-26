#!/usr/bin/env python3
"""
Simple retention job for SQLite to support archive/anonymize/purge modes.

Usage:
  python tools/retention_job.py --db test.db --mode archive --cutoff-days 365 --batch 100 --dry-run

Writes an audit row into `retention_audit`.
"""
import argparse
import sqlite3
import time
import datetime
import json
import os


def ensure_tables(conn):
    cur = conn.cursor()
    # visits table may be created by migration; create minimal schema for tests
    cur.execute("""
    CREATE TABLE IF NOT EXISTS visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id TEXT,
        user_id TEXT,
        point_id TEXT,
        timestamp INTEGER,
        duration_seconds INTEGER,
        accuracy_meters REAL,
        session_id TEXT,
        metadata TEXT
    )
    """)
    cur.execute("""
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
    )
    """)
    # create archive table if not exists
    cur.execute(open(os.path.join('src','infrastructure','sqlite','migrations','create_visits_archive.sql')).read())
    conn.commit()


def run(conn, mode='dry-run', cutoff_days=365, batch=100, dry_run=True):
    now = int(time.time())
    cutoff = now - int(cutoff_days) * 24 * 3600
    cur = conn.cursor()
    total_processed = 0
    start = int(time.time())

    while True:
        cur.execute('SELECT id FROM visits WHERE timestamp < ? LIMIT ?', (cutoff, batch))
        rows = cur.fetchall()
        if not rows:
            break
        ids = [r[0] for r in rows]
        total_processed += len(ids)
        if not dry_run:
            if mode == 'archive':
                cur.execute('INSERT INTO visits_archive (event_id,user_id,point_id,timestamp,duration_seconds,accuracy_meters,session_id,metadata) SELECT event_id,user_id,point_id,timestamp,duration_seconds,accuracy_meters,session_id,metadata FROM visits WHERE id IN (%s)' % ','.join(['?']*len(ids)), ids)
                cur.execute('DELETE FROM visits WHERE id IN (%s)' % ','.join(['?']*len(ids)), ids)
            elif mode == 'anonymize':
                cur.execute('UPDATE visits SET user_id=NULL, metadata=NULL WHERE id IN (%s)' % ','.join(['?']*len(ids)), ids)
            elif mode == 'purge':
                cur.execute('DELETE FROM visits WHERE id IN (%s)' % ','.join(['?']*len(ids)), ids)
            conn.commit()
    end = int(time.time())
    # insert audit
    cur.execute('INSERT INTO retention_audit (operation, affected_count, cutoff_timestamp, mode, started_at, completed_at, actor, details) VALUES (?,?,?,?,?,?,?,?)', (
        mode, total_processed, cutoff, mode, start, end, 'system', ''
    ))
    conn.commit()
    return {
        'processed': total_processed,
        'start': start,
        'end': end,
        'mode': mode,
        'dry_run': dry_run,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--db', default=':memory:')
    parser.add_argument('--mode', default='dry-run', choices=['dry-run','archive','anonymize','purge'])
    parser.add_argument('--cutoff-days', type=int, default=365)
    parser.add_argument('--batch', type=int, default=100)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()

    conn = sqlite3.connect(args.db)
    ensure_tables(conn)
    res = run(conn, mode=args.mode, cutoff_days=args.cutoff_days, batch=args.batch, dry_run=args.dry_run)
    print(json.dumps(res, indent=2))


if __name__ == '__main__':
    main()
