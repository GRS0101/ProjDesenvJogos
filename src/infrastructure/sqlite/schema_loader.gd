extends Node

"""
Schema loader for embedded SQLite migrations.
Placeholder: loads SQL files from `src/infrastructure/sqlite/migrations/`.
"""

func load_migrations(path: String) -> void:
    var dir = Directory.new()
    if dir.open(path) != OK:
        push_error("Migrations path not found: %s" % path)
        return
    dir.list_dir_begin(true, true)
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with('.sql'):
            var file = File.new()
            var full = path.plus_file(file_name)
            if file.file_exists(full):
                file.open(full, File.READ)
                var sql = file.get_as_text()
                file.close()
                # The actual execution requires a SQLite adapter; leave hook for adapter
                print("Loaded migration: %s" % full)
        file_name = dir.get_next()
    dir.list_dir_end()
