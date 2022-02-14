--rdt_LottableFormat_XER
execute rdt.rdtDropMsg  175001     , 175050	

execute rdt.rdtAddMsg 175001, 10, '175001InvalidBatch',    'us_english', 600
execute rdt.rdtAddMsg 175002, 10, '175002InvalidDay',    'us_english', 600
execute rdt.rdtAddMsg 175003, 10, '175003InvalidDay',    'us_english', 600




