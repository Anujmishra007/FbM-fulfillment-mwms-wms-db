-- rdtfnc_Move_UCC
execute rdt.rdtDropMsg 60601, 60650

execute rdt.rdtAddMsg 60601, 10, '60601 UCC needed',     'us_english', 514
execute rdt.rdtAddMsg 60602, 10, '60602 UCC DoubleScan', 'us_english', 514
execute rdt.rdtAddMsg 60603, 10, '60603 ToLOC needed',   'us_english', 514
execute rdt.rdtAddMsg 60604, 10, '60604 Invalid ToLOC',  'us_english', 514
execute rdt.rdtAddMsg 60605, 10, '60605 Diff facility',  'us_english', 514
execute rdt.rdtAddMsg 60606, 10, '60606^UPD UCC fail',   'us_english', 514
execute rdt.rdtAddMsg 60607, 10, '60607^FROMLOC needed', 'us_english', 514
execute rdt.rdtAddMsg 60608, 10, '60608^Inv FROMLOC',    'us_english', 514
execute rdt.rdtAddMsg 60609, 10, '60609^Diff facility',  'us_english', 514
execute rdt.rdtAddMsg 60610, 10, '60610^Invalid FromID', 'us_english', 514

