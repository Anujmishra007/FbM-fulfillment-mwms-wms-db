-- rdt_638RefNoLKUP04
exec rdt.rdtdropmsg 158401, 158450

execute rdt.rdtAddMsg 158401, 10, '158401Found MultiASN', 'us_english', 638
execute rdt.rdtAddMsg 158402, 10, '158402Found MultiASN', 'us_english', 638
execute rdt.rdtAddMsg 158403, 10, '158403ASN NotFound  ', 'us_english', 638
execute rdt.rdtAddMsg 158404, 10, '158404RFID ASN      ', 'us_english', 638
execute rdt.rdtAddMsg 158405, 10, 'BLACK LIST          ', 'us_english', 638

-- WMS-16506
execute rdt.rdtAddMsg 158406, 10, 'GROUP LIST          ', 'us_english', 638
execute rdt.rdtAddMsg 158407, 10, '158407OVER 14 DAYS  ', 'us_english', 638

-- WMS-16735
execute rdt.rdtAddMsg 158408, 10, 'Program Order       ', 'us_english', 638
execute rdt.rdtAddMsg 158409, 10, 'Must Receive        ', 'us_english', 638
