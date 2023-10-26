--rdt_608ExtInfo13
exec rdt.rdtDropMsg 206601 , 206650

execute rdt.rdtAddMsg 206601, 10, 'RETURN FINALIZED', 'us_english', 608
execute rdt.rdtAddMsg 206602, 10, 'SUCESSFULLY',      'us_english', 608


SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 206601 AND 206650



