--rdt_1829ExtUpd04
exec rdt.rdtDropMsg 134901 , 134950

execute rdt.rdtAddMsg 134901, 10, '34901^End Sort Fail',     'us_english', 1829
execute rdt.rdtAddMsg 134902, 10, '34902^Upd Qty Error',     'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 134901 AND 134950