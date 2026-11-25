"""Try to insert good and bad dates into the table and print what the schema accepts."""
import sqlite3, pathlib
con = sqlite3.connect(":memory:")
con.executescript((pathlib.Path(__file__).parent / "schema.sql").read_text())
cases = [
    ("valid reply", "2026-11-01", "2026-11-05"), ("no reply yet", "2026-11-01", None),
    ("leap day, valid", "2028-02-29", None), ("text instead of a date", "not a date", None),
    ("impossible 2026-02-30", "2026-02-30", None), ("impossible 2026-04-31", "2026-04-31", None),
    ("month 13", "2026-13-01", None), ("wrong format 11/01/2026", "11/01/2026", None),
    ("reply in 05/11/2026 format", "2026-11-01", "05/11/2026"), ("impossible reply date", "2026-11-01", "2026-02-30"),
    ("reply before sent", "2026-11-10", "2026-11-05"), ("date with a time", "2026-11-01 10:00", None),
    ("empty text", "", None), ("missing date sent", None, None),
    ("future date sent", "2027-05-01", None), ("future reply date", "2026-11-01", "2027-01-01"),
]
for i, (name, sent, reply) in enumerate(cases):
    try:
        con.execute("INSERT INTO transmittals VALUES (?,?,?,?,?,?,?,?)", (f"T{i}", "D", "t", "Civil", sent, "A", reply, None))
        result = "accepted"
    except sqlite3.IntegrityError:
        result = "rejected"
    print(f"{name:30} {result}")
