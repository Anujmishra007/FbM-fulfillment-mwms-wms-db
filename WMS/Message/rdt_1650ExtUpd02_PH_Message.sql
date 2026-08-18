-- 273001 - 273050

rdt.rdtDropMsg 273001 , 273050

execute rdt.rdtAddMsg 273001, 10, '273001 PALLET ID REQ',      'us_english', 1650
execute rdt.rdtAddMsg 273002, 10, '273002 Get RFKey Fail',     'us_english', 1650
execute rdt.rdtAddMsg 273003, 10, '273003 LOCK PDTL FAIL',     'us_english', 1650
execute rdt.rdtAddMsg 273004, 10, '273004 Lose ID Fail',       'us_english', 1650
execute rdt.rdtAddMsg 273005, 10, '273005 REL PDTL FAIL',      'us_english', 1650
execute rdt.rdtAddMsg 273006, 10, '273006 InsScn2TrkFail',     'us_english', 1650
execute rdt.rdtAddMsg 273007, 10, '273007 UPDATE ORDERS FAIL', 'us_english', 1650

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 273001 AND 273050
