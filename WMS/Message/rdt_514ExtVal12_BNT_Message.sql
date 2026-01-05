rdt.rdtDropMsg 255701 , 255750
 
execute rdt.rdtAddMsg 255701, 10, '255701^ID is Blank',   'us_english', 514
execute rdt.rdtAddMsg 255702, 10, '255702^Diff SKU in PickLoc',   'us_english', 514
execute rdt.rdtAddMsg 255703, 10, '255703^Over UCC Qty',   'us_english', 514
execute rdt.rdtAddMsg 255704, 10, '255704^Over Max SKU',   'us_english', 514
 
 
SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 255701 AND 255750