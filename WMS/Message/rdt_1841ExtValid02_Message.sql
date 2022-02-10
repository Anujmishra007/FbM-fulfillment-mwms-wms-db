--rdt_1841ExtValid02
exec rdt.rdtDropMsg 173501, 173550

execute rdt.rdtAddMsg 173501, 10, '173501 Invalid UCC  ',   'us_english', 1841



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 173501 AND 173550


