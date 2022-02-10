--rdt_840ExtUpd06
exec rdt.rdtDropMsg 133401 , 133450

execute rdt.rdtAddMsg 133401, 10, '33401^Setup CODEKLP',    'us_english', 840
execute rdt.rdtAddMsg 133402, 10, '33402^UPD PGET FAIL',    'us_english', 840
execute rdt.rdtAddMsg 133403, 10, '33403^DEL INVOICE ER',   'us_english', 840
execute rdt.rdtAddMsg 133404, 10, '33404^DEL INVOICE ER',   'us_english', 840
execute rdt.rdtAddMsg 133405, 10, '33405^DEL INVOICE ER',   'us_english', 840
execute rdt.rdtAddMsg 133406, 10, '33406^Packcfm fail',     'us_english', 840
execute rdt.rdtAddMsg 133407, 10, '33407^Upd wgt fail',     'us_english', 840
execute rdt.rdtAddMsg 133408, 10, 'NO INVOICE',             'us_english', 840
execute rdt.rdtAddMsg 133409, 10, 'PROCEED TO HOSPITAL',    'us_english', 840
execute rdt.rdtAddMsg 133410, 10, '33410^No Printer',       'us_english', 840

-- WMS-10768
execute rdt.rdtAddMsg 133411, 10, '33411^SKU WEIGHT = 0',    'us_english', 840
execute rdt.rdtAddMsg 133412, 10, '33412^UPDPKINFO Fail',    'us_english', 840
execute rdt.rdtAddMsg 133413, 10, '33413^INSPKINFO Fail',    'us_english', 840

-- WMS-15359
execute rdt.rdtAddMsg 133416, 10, '33416^UPDSOSTATUS ER',    'us_english', 840

-- WMS-16580
execute rdt.rdtAddMsg 133417, 10, '33417^ONLY 1 CARTON',     'us_english', 840
execute rdt.rdtAddMsg 133418, 10, '33418^X FINISH PACK',     'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 133401 and 133450



