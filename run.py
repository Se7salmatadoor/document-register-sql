"""Build an in-memory SQLite database from schema.sql and data.sql, run queries.sql, print the results."""
import sqlite3, pathlib, re
here = pathlib.Path(__file__).parent
con = sqlite3.connect(":memory:")
con.executescript((here / "schema.sql").read_text())
con.executescript((here / "data.sql").read_text())
sql = (here / "queries.sql").read_text()
blocks = [b for b in re.split(r"\n(?=-- Q\d)", sql) if b.lstrip().startswith("-- Q")]
for b in blocks:
    title = b.splitlines()[0][3:]
    stmt = "\n".join(l for l in b.splitlines() if not l.strip().startswith("--"))
    cur = con.execute(stmt)
    cols = [c[0] for c in cur.description]
    print(title)
    print(" | ".join(cols))
    for row in cur.fetchall():
        print(" | ".join(str(v) for v in row))
    print()
