-- rdt_UATransfer
exec rdt.rdtDropMsg 150251, 150300

execute rdt.rdtAddMsg 150251, 10, '150251WRONG LOT TYPE', 'us_english', 0
execute rdt.rdtAddMsg 150252, 10, '150252WITHDRAW FAIL ', 'us_english', 0
execute rdt.rdtAddMsg 150253, 10, '150253DEPOSIT FAIL  ', 'us_english', 0
