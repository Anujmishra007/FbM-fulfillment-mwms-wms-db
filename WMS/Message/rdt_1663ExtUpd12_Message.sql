--rdt_1663ExtUpd12
execute rdt.rdtDropMsg 196001 , 196050

execute rdt.rdtAddMsg 196001, 10, '196001Insert TL2 Err',   'us_english', 1663
execute rdt.rdtAddMsg 196002, 10, '196002Upd Mbol Err  ',   'us_english', 1663

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 196001 AND 196050

