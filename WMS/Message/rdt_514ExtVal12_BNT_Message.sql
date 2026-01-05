rdt.rdtDropMsg 255501 , 255550
 
execute rdt.rdtAddMsg 255501, 10, '255501^ID is Blank',   'us_english', 514
execute rdt.rdtAddMsg 255502, 10, '255502^Diff SKU in PickLoc',   'us_english', 514
execute rdt.rdtAddMsg 255503, 10, '255503^Over UCC Qty',   'us_english', 514
execute rdt.rdtAddMsg 255504, 10, '255504^Over Max SKU',   'us_english', 514
 
 
SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 255501 AND 255550