-- rdt_600DecodeSP03
execute rdt.rdtDropMsg 105551, 105600

execute rdt.rdtAddMsg 105551, 10, '105551Invalid L06   ',   'us_english', 600
execute rdt.rdtAddMsg 105552, 10, '105552Invalid L02   ',   'us_english', 600
execute rdt.rdtAddMsg 105553, 10, '105553Invalid QTY   ',   'us_english', 600
execute rdt.rdtAddMsg 105554, 10, '105554Invalid UPC   ',   'us_english', 600
execute rdt.rdtAddMsg 105555, 10, '105555Invalid SKU   ',   'us_english', 600
execute rdt.rdtAddMsg 105556, 10, '105556Invalid UOM   ',   'us_english', 600
execute rdt.rdtAddMsg 105557, 10, '105557InvalidPackCNT',   'us_english', 600
execute rdt.rdtAddMsg 105558, 10, '105558Invalid SKU   ',   'us_english', 600

-- WMS10133
execute rdt.rdtAddMsg 105559, 10, '105559Invalid L04   ',   'us_english', 600
