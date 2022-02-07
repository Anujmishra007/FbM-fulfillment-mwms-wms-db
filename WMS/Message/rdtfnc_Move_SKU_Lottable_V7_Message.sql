-- rdtfnc_Move_SKU_Lottable_V7
execute rdt.rdtDropMsg 125551 , 125600

execute rdt.rdtAddMsg 125551, 10, '25551^LOC needed',     'us_english', 629
execute rdt.rdtAddMsg 125552, 10, '25552^Invalid LOC',    'us_english', 629
execute rdt.rdtAddMsg 125553, 10, '25553^Diff facility',  'us_english', 629
execute rdt.rdtAddMsg 125554, 10, '25554^LOC have UCC',   'us_english', 629
execute rdt.rdtAddMsg 125555, 10, '25555^Invalid ID',     'us_english', 629
execute rdt.rdtAddMsg 125556, 10, '25556^SKU needed',     'us_english', 629
execute rdt.rdtAddMsg 125557, 10, '25557^Invalid SKU',    'us_english', 629
execute rdt.rdtAddMsg 125558, 10, '25558^SameBarCodeSKU', 'us_english', 629
execute rdt.rdtAddMsg 125559, 10, '25559^No QTY to move', 'us_english', 629
execute rdt.rdtAddMsg 125560, 10, '25560^No QTY to move', 'us_english', 629
execute rdt.rdtAddMsg 125561, 10, '25561^No more record', 'us_english', 629
execute rdt.rdtAddMsg 125562, 10, '25562^Invalid QTY',    'us_english', 629
execute rdt.rdtAddMsg 125563, 10, '25563^Invalid QTY',    'us_english', 629
execute rdt.rdtAddMsg 125564, 10, '25564^QTY needed',     'us_english', 629
execute rdt.rdtAddMsg 125565, 10, '25565^QTYAVL NotEnuf', 'us_english', 629
execute rdt.rdtAddMsg 125566, 10, '25566^ToLOC needed',   'us_english', 629
execute rdt.rdtAddMsg 125567, 10, '25567^Invalid LOC',    'us_english', 629
execute rdt.rdtAddMsg 125568, 10, '25568^Diff facility',  'us_english', 629
execute rdt.rdtAddMsg 125569, 10, '25569^Inv changed',    'us_english', 629

--WMS-16449
execute rdt.rdtAddMsg 125570, 10, '25570^LOC Not Match',  'us_english', 629

select * from rdt.rdtmsg (nolock) where message_id between 125551 and 125600
