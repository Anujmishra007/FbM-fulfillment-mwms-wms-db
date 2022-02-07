--rdt_1854SwapID01
exec rdt.rdtDropMsg 174601, 174650

execute rdt.rdtAddMsg 174601, 10, '74601InvalidID/Lot02', 'us_english', 1854
execute rdt.rdtAddMsg 174602, 10, '174602^Invalid ID   ', 'us_english', 1854
execute rdt.rdtAddMsg 174603, 10, '174603^ID multi rec ', 'us_english', 1854
execute rdt.rdtAddMsg 174604, 10, '174604^LOC not match', 'us_english', 1854
execute rdt.rdtAddMsg 174605, 10, '174605^SKU not match', 'us_english', 1854
execute rdt.rdtAddMsg 174606, 10, '174606^QTY not match', 'us_english', 1854
execute rdt.rdtAddMsg 174607, 10, '174607^ID Picked    ', 'us_english', 1854
execute rdt.rdtAddMsg 174608, 10, '174608^L01 Not Match', 'us_english', 1854
execute rdt.rdtAddMsg 174609, 10, '174609^L05 Not Match', 'us_english', 1854
execute rdt.rdtAddMsg 174610, 10, '174610^L06 Not Match', 'us_english', 1854
execute rdt.rdtAddMsg 174611, 10, '174611^L07 Not Match', 'us_english', 1854
execute rdt.rdtAddMsg 174612, 10, '174612^L08 Not Match', 'us_english', 1854
execute rdt.rdtAddMsg 174613, 10, '174613^L12 Not Match', 'us_english', 1854
execute rdt.rdtAddMsg 174614, 10, '174614^TaskOffsetErr', 'us_english', 1854
execute rdt.rdtAddMsg 174615, 10, '174615NothingSwapped', 'us_english', 1854
execute rdt.rdtAddMsg 174616, 10, '174616^InvalidID    ', 'us_english', 1854
execute rdt.rdtAddMsg 174617, 10, '174617^Lot02 Picked ', 'us_english', 1854
execute rdt.rdtAddMsg 174618, 10, '174618^L02 Not Match', 'us_english', 1854
execute rdt.rdtAddMsg 174619, 10, '174619^TaskOffsetErr', 'us_english', 1854
execute rdt.rdtAddMsg 174620, 10, '174620^TaskOffsetErr', 'us_english', 1854
execute rdt.rdtAddMsg 174621, 10, '174621^TaskOffsetErr', 'us_english', 1854
execute rdt.rdtAddMsg 174622, 10, '174622^TaskOffsetErr', 'us_english', 1854
execute rdt.rdtAddMsg 174623, 10, '174623^Diff ID      ', 'us_english', 1854

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 174601 AND 174650
