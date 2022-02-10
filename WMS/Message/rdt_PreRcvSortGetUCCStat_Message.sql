-- rdt_PreRcvSortGetUCCStat
exec rdt.rdtDropMsg 106051 , 106100

execute rdt.rdtAddMsg 106051, 10, '106051^INSERT POS ERR',    'us_english', 1825
execute rdt.rdtAddMsg 106052, 10, '106052^UPDATE POS ERR',    'us_english', 1825