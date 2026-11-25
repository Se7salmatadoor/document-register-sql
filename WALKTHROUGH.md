# Walkthrough: from a register to answers in SQL

## Step 1. One table, one row per transmittal
Look at `schema.sql`. Each column is one fact: transmittal number, document number, title, discipline, date sent, revision, date of reply, reply status. A reply that has not come yet is stored as NULL, not as an empty string. The primary key is the transmittal number, so a number cannot appear twice.

## Step 2. Store dates as ISO text
Dates are text in the form `yyyy-mm-dd`. SQLite has no date type, but this form sorts correctly and works with `date()`, `julianday()` and `strftime()`.

## Step 3. Make the table refuse bad dates
The `CHECK` lines reject text that is not a date, impossible dates, and a reply before the send date. Two traps: a `CHECK` that evaluates to NULL passes, so each rule starts with `IS NOT NULL`; and `date('2026-02-30')` is not NULL in SQLite 3.37, so the rule converts the date to a day number and back and compares. Run `python3 test_validation.py` to see 16 cases. Future dates are not rejected by the table in this example, so results stay reproducible. Treat them as quality exceptions: Q7 lists them. This is a partial check, not complete validation.

## Step 4. Load the data
`data.sql` has 30 dummy rows. Same rows as the Excel tracker project.

## Step 5. Write the questions
Open `queries.sql`. Each query has a comment. The ideas:
- Days waiting = `julianday(as_of_date) - julianday(date_sent)`.
- Status uses `CASE`: has a reply date = Closed; no reply and more than 14 days = Overdue; otherwise Open.
- `GROUP BY` with `COUNT(*)` and `AVG(...)` gives counts and averages per group.
- `strftime('%Y-%m', date_sent)` groups by month.
- A subquery turns days waiting into buckets (0-7, 8-14, 15-30, 31+).

## Step 6. Run and check
`python3 run.py` prints all results. Compare them with `EXPECTED_OUTPUT.md`. Then check one by hand: T-006 was sent on 2026-10-17, so on 2026-11-25 it has waited 39 days and is overdue.

## Limits
SQLite only. The as-of date is fixed at 2026-11-25 for repeatable results. Dummy data.
