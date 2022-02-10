--rdt_1663ExtVal09
exec rdt.rdtdropmsg 150301 , 150350	

execute rdt.rdtAddMsg 150301, 10, '50301^Inv Ord Status',   'us_english', 1663
execute rdt.rdtAddMsg 150302, 10, '50302^Diff Ord Type',    'us_english', 1663
execute rdt.rdtAddMsg 150303, 10, '50303^Diff Carrier',     'us_english', 1663
execute rdt.rdtAddMsg 150304, 10, '50304^Diff MBOLKey',     'us_english', 1663
execute rdt.rdtAddMsg 150305, 10, '50305^No Region',        'us_english', 1663
execute rdt.rdtAddMsg 150306, 10, '50306^Mbol > 1 Region',  'us_english', 1663
execute rdt.rdtAddMsg 150307, 10, '50307^Invalid Region',   'us_english', 1663
execute rdt.rdtAddMsg 150308, 10, '50308^Pls Try A',        'us_english', 1663
execute rdt.rdtAddMsg 150309, 10, '50309^New MBOL',         'us_english', 1663

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 150301 AND 150350
