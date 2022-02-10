--rdt_MultiSKUBarcode
execute rdt.rdtDropMsg 81151, 81200

execute rdt.rdtAddMsg 81151, 10, '81151 Invalid option',   'us_english'
execute rdt.rdtAddMsg 81152, 10, '81152 SKU1 blank    ',   'us_english'
execute rdt.rdtAddMsg 81153, 10, '81153 SKU2 blank    ',   'us_english'
execute rdt.rdtAddMsg 81154, 10, '81154 SKU3 blank    ',   'us_english'
execute rdt.rdtAddMsg 81155, 10, '81155 No more SKU   ',   'us_english'
execute rdt.rdtAddMsg 81156, 10, '81156 No more record',   'us_english'
