-- rdt_LotOrder_Reset
execute rdt.rdtDropMsg 198501, 198550

execute rdt.rdtAddMsg 198501, 10, '198501DEL LOG Fail  ', 'us_english', 655
execute rdt.rdtAddMsg 198502, 10, '198502DEL PKDtl Fail', 'us_english', 655
execute rdt.rdtAddMsg 198503, 10, '198503DEL LOG Fail  ', 'us_english', 655
execute rdt.rdtAddMsg 198504, 10, '198504UPD LOG Fail  ', 'us_english', 655