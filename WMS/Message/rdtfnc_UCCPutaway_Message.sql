-- rdtfnc_UCCPutaway (range 50011 - 50020)
-- rdt.rdtdropmsg 50011, 50020
-- rdt.rdtdropmsg 85601, 85650

execute rdt.rdtAddMsg 50011, 10, '50011^UCC REQ',        'us_english'
execute rdt.rdtAddMsg 50012, 10, '50012^INVALID UCC',    'us_english'
execute rdt.rdtAddMsg 50013, 10, '50013^MIX SKU UCC',    'us_english'
execute rdt.rdtAddMsg 50014, 10, '50014^MIX SKU UCC',    'us_english'
execute rdt.rdtAddMsg 50015, 10, '50015^Fail RDTPASTD',  'us_english'
execute rdt.rdtAddMsg 50016, 10, '50016^NoSuitableLOC',  'us_english'
execute rdt.rdtAddMsg 50017, 10, '50017^ToLOC REQ',      'us_english'
execute rdt.rdtAddMsg 50018, 10, '50018^ToLOC X MATCH',  'us_english'
execute rdt.rdtAddMsg 50019, 10, '50019^Invalid ToLOC',  'us_english'
execute rdt.rdtAddMsg 50020, 10, '50020^UPD UCC FAIL',   'us_english'

execute rdt.rdtAddMsg 85601, 10, '85601^OPTION REQ',     'us_english'
execute rdt.rdtAddMsg 85602, 10, '85602^INVALID OPTION', 'us_english'
execute rdt.rdtAddMsg 85603, 10, '85603^Fail RDTPASTD',  'us_english'
execute rdt.rdtAddMsg 85604, 10, '85604^NoSuitableLOC',  'us_english'
execute rdt.rdtAddMsg 85605, 10, '85605^NO RECORD 2 MV', 'us_english'
execute rdt.rdtAddMsg 85606, 10, '85606^QTY ALLOC > 0',  'us_english'

--wms-16559
execute rdt.rdtAddMsg 85607, 10, '85607^Option req',  'us_english'
execute rdt.rdtAddMsg 85608, 10, '85608^Invalid Option',  'us_english'

