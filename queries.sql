-- All queries use one parameter: the "as of" date. Here it is fixed so the results
-- in EXPECTED_OUTPUT.md are reproducible. Replace '2026-11-25' with date('now') for live use.
-- Review period: 14 days.

-- Q1. Status counts
-- Closed = has a reply date. Overdue = no reply and waiting more than 14 days. Open = the rest.
SELECT status, COUNT(*) AS items
FROM (
  SELECT CASE
           WHEN date_reply IS NOT NULL THEN 'Closed'
           WHEN julianday('2026-11-25') - julianday(date_sent) > 14 THEN 'Overdue'
           ELSE 'Open'
         END AS status
  FROM transmittals
)
GROUP BY status
ORDER BY CASE status WHEN 'Overdue' THEN 1 WHEN 'Open' THEN 2 ELSE 3 END;

-- Q2. Overdue list, oldest first
SELECT trans_no, doc_no, discipline, date_sent,
       CAST(julianday('2026-11-25') - julianday(date_sent) AS INTEGER) AS days_waiting
FROM transmittals
WHERE date_reply IS NULL
  AND julianday('2026-11-25') - julianday(date_sent) > 14
ORDER BY days_waiting DESC;

-- Q3. Average days to reply by discipline (closed items only)
SELECT discipline,
       COUNT(*) AS closed_items,
       ROUND(AVG(julianday(date_reply) - julianday(date_sent)), 1) AS avg_days_to_reply
FROM transmittals
WHERE date_reply IS NOT NULL
GROUP BY discipline
ORDER BY discipline;

-- Q4. Ageing of items still waiting
SELECT bucket, COUNT(*) AS items
FROM (
  SELECT CASE
           WHEN d <= 7  THEN '0-7'
           WHEN d <= 14 THEN '8-14'
           WHEN d <= 30 THEN '15-30'
           ELSE '31+'
         END AS bucket
  FROM (SELECT CAST(julianday('2026-11-25') - julianday(date_sent) AS INTEGER) AS d
        FROM transmittals WHERE date_reply IS NULL)
)
GROUP BY bucket
ORDER BY CASE bucket WHEN '0-7' THEN 1 WHEN '8-14' THEN 2 WHEN '15-30' THEN 3 ELSE 4 END;

-- Q5. Sent per month
SELECT strftime('%Y-%m', date_sent) AS month, COUNT(*) AS sent
FROM transmittals
GROUP BY month
ORDER BY month;

-- Q6. Rejected items and how long the reply took
SELECT trans_no, doc_no, discipline,
       CAST(julianday(date_reply) - julianday(date_sent) AS INTEGER) AS days_to_reply
FROM transmittals
WHERE reply_status = 'Rejected'
ORDER BY days_to_reply DESC;

-- Q7. Data quality: future dates
-- In this example the schema does not reject future dates (it has no rule that depends on today's date),
-- so look for them with a query. Expected: no rows on the dummy data.
SELECT trans_no, date_sent, date_reply
FROM transmittals
WHERE date_sent > '2026-11-25'
   OR (date_reply IS NOT NULL AND date_reply > '2026-11-25');
