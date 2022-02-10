--rdt_608RcvCfm02
exec rdt.rdtDropMsg 121051 , 121100

execute rdt.rdtAddMsg 121051, 10, '21051^OVER RECEIVE',     'us_english', 608
execute rdt.rdtAddMsg 121052, 10, '21052^UPD RCHDR FAIL',   'us_english', 608

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 121051 AND 121100



