
EXECUTE rdt.rdtDropMsg 254001, 254050

EXECUTE rdt.rdtAddMsg 254001, 10, '254001PltStatusNot0', 'us_english', 1638, 0, '254001 Scanned Pallet should be in status 0'
EXECUTE rdt.rdtAddMsg 254002, 10, '254002MBOLs not fully loaded', 'us_english', 1638, 0, '254002 MBOLs not fully loaded'
EXECUTE rdt.rdtAddMsg 254003, 10, '254003UpdMBOLFailed', 'us_english', 1638, 0, '254003Upd MBOLs Failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 254001 AND 254050
