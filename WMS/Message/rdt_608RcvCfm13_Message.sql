--rdt_608RcvCfm13
exec rdt.rdtDropMsg 184051 , 184100

execute rdt.rdtAddMsg 184051, 10, '118405 OVER RECEIVE ',   'us_english', 608
execute rdt.rdtAddMsg 184052, 10, '118405 UPD RCHDR ERR',   'us_english', 608

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 184051 AND 184100



