--rdtfnc_Flowthru_CartonReceive
execute rdt.rdtdropmsg 85451, 85500    

execute rdt.rdtAddMsg 85451, 10, '85451^NeedShipmentID', 'us_english', 587
execute rdt.rdtAddMsg 85452, 10, '85452^Invalid Format', 'us_english', 587
execute rdt.rdtAddMsg 85453, 10, '85453^Need Brand    ', 'us_english', 587
execute rdt.rdtAddMsg 85454, 10, '85454^Invalid Brand ', 'us_english', 587
execute rdt.rdtAddMsg 85455, 10, '85455^Need From Shop', 'us_english', 587
execute rdt.rdtAddMsg 85456, 10, '85456^Bad From Shop ', 'us_english', 587
execute rdt.rdtAddMsg 85457, 10, '85457^Need To Shop  ', 'us_english', 587
execute rdt.rdtAddMsg 85458, 10, '85458^Invalid ToShop', 'us_english', 587
execute rdt.rdtAddMsg 85459, 10, '85459^SameFromToShop', 'us_english', 587
execute rdt.rdtAddMsg 85460, 10, '85460^nspg_getkey   ', 'us_english', 587
execute rdt.rdtAddMsg 85461, 10, '85461^INS RCP Fail  ', 'us_english', 587
execute rdt.rdtAddMsg 85462, 10, '85462^Need CartonID ', 'us_english', 587
execute rdt.rdtAddMsg 85463, 10, '85463^Invalid Format', 'us_english', 587
execute rdt.rdtAddMsg 85464, 10, '85464^Double scan   ', 'us_english', 587
execute rdt.rdtAddMsg 85465, 10, '85465^Double scan   ', 'us_english', 587
execute rdt.rdtAddMsg 85466, 10, '85466^Used CartonID ', 'us_english', 587
execute rdt.rdtAddMsg 85467, 10, '85467^INS RCDtl Fail', 'us_english', 587
execute rdt.rdtAddMsg 85468, 10, '85468^Receipt Closed', 'us_english', 587
