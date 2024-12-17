execute rdt.rdtDropMsg 228601, 228650

execute rdt.rdtAddMsg 228601, 10, '228601 Upd Fail', 'us_english', 1841, 0, N'228601 Upd Fail'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 228601 AND 228650