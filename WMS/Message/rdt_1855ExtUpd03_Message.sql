--rdt_1855ExtUpd03
--FCR-1755
exec rdt.rdtDropMsg 230851 , 230900

execute rdt.rdtAddMsg 230851, 10, '230851InsTL2LogErr',        'us_english', 1855

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 230851 AND 230900


