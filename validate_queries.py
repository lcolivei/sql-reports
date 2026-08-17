from pathlib import Path
import sqlite3

root = Path(__file__).parent
connection = sqlite3.connect(':memory:')
connection.executescript((root / 'schema.sql').read_text(encoding='utf-8'))
connection.executescript((root / 'seed.sql').read_text(encoding='utf-8'))

queries = []
current = []
for line in (root / 'queries.sql').read_text(encoding='utf-8').splitlines():
    if line.strip().startswith('--') and current and any(part.strip() for part in current):
        statement = '\n'.join(current).strip()
        if statement:
            queries.append(statement)
        current = []
    current.append(line)
if any(part.strip() for part in current):
    queries.append('\n'.join(current).strip())

executed = 0
for query in queries:
    sql = '\n'.join(line for line in query.splitlines() if not line.strip().startswith('--')).strip()
    if not sql:
        continue
    connection.execute(sql).fetchall()
    executed += 1

print(f'{executed} consultas SQL executadas com sucesso.')
connection.close()
