-- Document register: one row per transmittal. Dummy data only.
CREATE TABLE transmittals (
    trans_no     TEXT PRIMARY KEY,
    doc_no       TEXT NOT NULL,
    title        TEXT NOT NULL,
    discipline   TEXT NOT NULL,
    date_sent    TEXT NOT NULL,      -- ISO date, yyyy-mm-dd
    rev          TEXT NOT NULL,
    date_reply   TEXT,               -- NULL means no reply yet
    reply_status TEXT,               -- Approved / Approved with comments / Rejected
    -- A CHECK that evaluates to NULL PASSES in SQLite, and date() returns NULL for bad text, so every
    -- test below first says IS NOT NULL. In SQLite 3.37, date() alone lets 2026-02-30 through (it only range-checks
    -- the day as 1-31), so the date is converted to a day number and back and must come out unchanged.
    CHECK (julianday(date_sent) IS NOT NULL AND date(julianday(date_sent)) = date_sent),
    CHECK (date_reply IS NULL OR (julianday(date_reply) IS NOT NULL AND date(julianday(date_reply)) = date_reply)),
    CHECK (date_reply IS NULL OR date_reply >= date_sent)
);
