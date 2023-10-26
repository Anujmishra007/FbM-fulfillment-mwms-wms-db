--rdt_1841ExtValid04
exec rdt.rdtDropMsg 207701 , 207750

execute rdt.rdtAddMsg 207701, 10, '207701 Invalid UCC ', 'us_english', 1841
execute rdt.rdtAddMsg 207702, 10, '207702 CBM required', 'us_english', 1841

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 207701 AND 207750



