# Document Register in SQL (SQLite)

![Example output of the SQL register queries (dummy data)](images/sql-output.png)

A small SQL project built around a document control transmittal register: which items were sent, which got a reply, which are overdue, and how long replies take. It uses SQLite, so there is nothing to install beyond Python (or the `sqlite3` command line tool).

All data is dummy data made for demonstration. It contains no employer or project data. It is the same 30 rows as the Excel tracker project, so you can compare the answers.

## Files
| File | What it does |
|---|---|
| `schema.sql` | One table, `transmittals`, with a check that a reply cannot be dated before it was sent. |
| `reset.sql` | Optional. Deletes the table, with a warning at the top. Not run by anything else. |
| `data.sql` | 30 dummy rows. |
| `queries.sql` | Seven queries, each explained in a comment. Q7 finds future dates. |
| `test_validation.py` | Tries good and bad dates against the schema. |
| `run.py` | Builds an in-memory database, runs the queries, prints the results. |
| `EXPECTED_OUTPUT.md` | What the queries return. |

## Run it
```
python3 run.py
```
`schema.sql` only creates the table; if you run it twice on the same database it stops with an error instead of erasing your data. Use `reset.sql` only when you want to start over.

Or with the SQLite command line: `sqlite3 :memory: ".read schema.sql" ".read data.sql" ".read queries.sql"`.

## Walkthrough
Step by step: [WALKTHROUGH.md](WALKTHROUGH.md) (English), [WALKTHROUGH.ar.md](WALKTHROUGH.ar.md) (Arabic).

## The queries
1. Status counts (Closed, Overdue, Open).
2. Overdue list, oldest first.
3. Average days to reply by discipline, closed items only.
4. Ageing of items still waiting (0-7, 8-14, 15-30, 31+ days).
5. Items sent per month.
6. Rejected items and how long the reply took.
7. Data quality: dates in the future.

Rules used: Closed means there is a reply date. Overdue means no reply and more than 14 days waiting. Open is the rest. The queries use a fixed "as of" date, 2026-11-25, so the results never change. For live use, replace `'2026-11-25'` with `date('now')`.

## What the date validation does, and what it does not
The `CHECK` rules in `schema.sql` reject: text that is not a date, impossible dates (2026-02-30, month 13), other formats (11/01/2026), dates with a time, an empty or missing date sent, and a reply dated before the send date. `test_validation.py` tries 16 cases; the output is below.

It does **not** reject future dates. In this example the table has no rule that depends on today's date, which keeps the results reproducible. Future-dated rows are treated as quality exceptions: Q7 lists them, and on the dummy data it returns none. It does not check that the discipline or reply status is from a fixed list. This is a partial check for a learning project, not complete validation and not a production design. Two SQLite details to know: a `CHECK` that evaluates to NULL passes (so every date rule starts with `IS NOT NULL`), and `date('2026-02-30')` is not NULL in SQLite 3.37, so the rule converts the date to a day number and back. Tested on SQLite 3.37 only; other versions may behave differently.

```
valid reply                    accepted
no reply yet                   accepted
leap day, valid                accepted
text instead of a date         rejected
impossible 2026-02-30          rejected
impossible 2026-04-31          rejected
month 13                       rejected
wrong format 11/01/2026        rejected
reply in 05/11/2026 format     rejected
impossible reply date          rejected
reply before sent              rejected
date with a time               rejected
empty text                     rejected
missing date sent              rejected
future date sent               accepted
future reply date              accepted
```

## How it was checked
The results of Q1 to Q6 were compared with an independent calculation in Python on the same rows. They match. The totals also match the Excel tracker on the same data (30 items, 10 waiting, 7 overdue, same average reply days per discipline). Checked with SQLite 3.37 through Python. Not checked on other SQL databases: the date functions (`julianday`, `strftime`) are SQLite specific.

## Rights
© 2026 Hussein Abdallah. All rights reserved for the original content. See [NOTICE.md](NOTICE.md).

Author: Hussein Abdallah, Document Controller.
