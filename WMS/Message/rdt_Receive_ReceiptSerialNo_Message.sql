-- rdt_Receive_ReceiptSerialNo
execute rdt.rdtDropMsg 142751, 142800

execute rdt.rdtAddMsg 142751, 10, '142751INS RDSNo Fail', 'us_english'
execute rdt.rdtAddMsg 142752, 10, '142752SNO Diff SKU',   'us_english'
execute rdt.rdtAddMsg 142753, 10, '142753SNO Diff QTY',   'us_english'
execute rdt.rdtAddMsg 142754, 10, '142754SNO ady rcv',    'us_english'
execute rdt.rdtAddMsg 142755, 10, '142755UPD RSNO Fail',  'us_english'
execute rdt.rdtAddMsg 142756, 10, '142756SNOMultiRecord', 'us_english'
