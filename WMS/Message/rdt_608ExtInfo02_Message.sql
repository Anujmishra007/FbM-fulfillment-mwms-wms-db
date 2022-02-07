--rdt_608ExtInfo02
exec rdt.rdtDropMsg 123401 , 123450

execute rdt.rdtAddMsg 123401, 10, 'RETURN FINALIZED', 'us_english', 608
execute rdt.rdtAddMsg 123402, 10, 'SUCESSFULLY',      'us_english', 608

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 123401 AND 123450



