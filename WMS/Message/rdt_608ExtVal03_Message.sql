--rdt_608ExtVal03
exec rdt.rdtDropMsg 121201 , 121250

execute rdt.rdtAddMsg 121201, 10, '21201^SKU In 2 ID',   'us_english', 608

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 121201 AND 121250



