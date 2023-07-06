-- rdt_629Confirm01
exec rdt.rdtDropMsg 199701, 199750

execute rdt.rdtAddMsg 199701, 10, '199701CreateLOT fail', 'us_english', 629
execute rdt.rdtAddMsg 199702, 10, '199702LookupLOT fail', 'us_english', 629
execute rdt.rdtAddMsg 199703, 10, '199703WITHDRAW FAIL ', 'us_english', 629
execute rdt.rdtAddMsg 199704, 10, '199704DEPOSIT FAIL  ', 'us_english', 629
execute rdt.rdtAddMsg 199705, 10, '199705Inv changed   ', 'us_english', 629
