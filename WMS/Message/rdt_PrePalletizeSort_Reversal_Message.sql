-- rdt_PrePalletizeSort_Reversal
exec rdt.rdtDropMsg 207401 , 207450

execute rdt.rdtAddMsg 207401, 10, '207401 Reversal Fail',     'us_english', 1865

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 207401 AND 207450

