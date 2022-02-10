-- rdt_Decode
execute rdt.rdtdropmsg 99001, 99050

execute rdt.rdtAddMsg 99001, 10, '99001 Bad NUM length', 'us_english'
execute rdt.rdtAddMsg 99002, 10, '99002 Bad Decimal   ', 'us_english'
