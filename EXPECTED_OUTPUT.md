# Expected output

Output of `python3 run.py` with the as-of date fixed at 2026-11-25. Ageing shows only buckets that have items (no item is in 8-14). Q7 returns no rows.

```
Q1. Status counts
status | items
Overdue | 7
Open | 3
Closed | 20

Q2. Overdue list, oldest first
trans_no | doc_no | discipline | date_sent | days_waiting
T-006 | DOC-CIV-105 | Civil | 2026-10-17 | 39
T-012 | DOC-ARC-111 | Architectural | 2026-10-27 | 29
T-028 | DOC-MEC-127 | Mechanical | 2026-10-30 | 26
T-015 | DOC-PIP-114 | Piping | 2026-11-02 | 23
T-001 | DOC-CIV-100 | Civil | 2026-11-03 | 22
T-021 | DOC-CIV-120 | Civil | 2026-11-04 | 21
T-026 | DOC-CIV-125 | Civil | 2026-11-06 | 19

Q3. Average days to reply by discipline (closed items only)
discipline | closed_items | avg_days_to_reply
Architectural | 4 | 15.8
Civil | 1 | 10.0
Electrical | 6 | 11.3
Mechanical | 4 | 10.0
Piping | 5 | 8.4

Q4. Ageing of items still waiting
bucket | items
0-7 | 3
15-30 | 6
31+ | 1

Q5. Sent per month
month | sent
2026-09 | 2
2026-10 | 14
2026-11 | 14

Q6. Rejected items and how long the reply took
trans_no | doc_no | discipline | days_to_reply
T-022 | DOC-ARC-121 | Architectural | 16
T-014 | DOC-ELE-113 | Electrical | 13
T-008 | DOC-MEC-107 | Mechanical | 8
T-010 | DOC-PIP-109 | Piping | 7

Q7. Data quality: future dates
trans_no | date_sent | date_reply

```
