--rdt_701ExtUpdSP01
--exec rdt.rdtDropMsg 50451, 50500

execute rdt.rdtAddMsg 50451, 10, '50451^CLOCK IN FAIL',    'us_english', 701
execute rdt.rdtAddMsg 50452, 10, '50452^CLOCK OUT FAIL',   'us_english', 701
execute rdt.rdtAddMsg 50453, 10, '50453^CLOCK OUT FAIL',   'us_english', 701
