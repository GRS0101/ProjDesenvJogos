import sqlite3
import time
import os
import tempfile
import json
import subprocess

def create_sample_db(path):
    conn = sqlite3.connect(path)
    cur = conn.cursor()
    cur.execute('''
    CREATE TABLE visits (
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
    ''')
    # insert rows: some older than cutoff (2 years), some recent
    now = int(time.time())
    old_ts = now - 365*24*3600*2
    recent_ts = now - 100
    rows = []
    for i in range(5):
        rows.append(('evt-old-%d' % i, 'user-1', 'pt-1', old_ts, 10, 5.0, 's1', '{}'))
    for i in range(3):
        rows.append(('evt-new-%d' % i, 'user-2', 'pt-2', recent_ts, 5, 3.0, 's2', '{}'))
    cur.executemany('INSERT INTO visits (event_id,user_id,point_id,timestamp,duration_seconds,accuracy_meters,session_id,metadata) VALUES (?,?,?,?,?,?,?,?)', rows)
    conn.commit()
    conn.close()


def test_archive_mode_creates_archive_and_deletes_old_rows(tmp_path):
    db_path = str(tmp_path / 'test.db')
    create_sample_db(db_path)
    # run migration script to create visits_archive
    migrations_sql = os.path.join('src','infrastructure','sqlite','migrations','create_visits_archive.sql')
    conn = sqlite3.connect(db_path)
    conn.executescript(open(migrations_sql).read())
    conn.commit()
    conn.close()

    # run retention tool in archive mode (not dry-run)
    cmd = ['python', 'tools/retention_job.py', '--db', db_path, '--mode', 'archive']
    res = subprocess.run(cmd, capture_output=True, text=True)
    assert res.returncode == 0
    out = json.loads(res.stdout)

    # verify audit and archive table
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute('SELECT COUNT(*) FROM visits_archive')
    archived_count = cur.fetchone()[0]
    cur.execute('SELECT COUNT(*) FROM visits')
    remaining = cur.fetchone()[0]
    conn.close()

    assert archived_count == 5
    assert remaining == 3
