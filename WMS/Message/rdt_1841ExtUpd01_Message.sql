--rdt_1841ExtUPD01
exec rdt.rdtDropMsg 177751, 177800

execute rdt.rdtAddMsg 177751, 10, '177751 INS UCC Fail ',   'us_english', 1841



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 177751 AND 177800


