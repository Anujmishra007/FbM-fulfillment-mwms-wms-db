

--rdt_1663ExtVal26
exec rdt.rdtdropmsg 206651 , 206700	

execute rdt.rdtAddMsg 206651, 10, '206651Inv Ord Status',   'us_english', 1663
execute rdt.rdtAddMsg 206652, 10, '206652Diff Ord Type',    'us_english', 1663
execute rdt.rdtAddMsg 206653, 10, '206653Diff Carrier',     'us_english', 1663
execute rdt.rdtAddMsg 206654, 10, '206654Diff MBOLKey',     'us_english', 1663
execute rdt.rdtAddMsg 206655, 10, '206655No Region',        'us_english', 1663
execute rdt.rdtAddMsg 206656, 10, '206656Mbol > 1 Region',  'us_english', 1663
execute rdt.rdtAddMsg 206657, 10, '206657Diff Region',   'us_english', 1663

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 206651 AND 206700
