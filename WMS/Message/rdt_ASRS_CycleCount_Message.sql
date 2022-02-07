--rdt_ASRS_CycleCount
execute rdt.rdtdropmsg 53951 , 54000

execute rdt.rdtAddMsg 53951, 10, '53951^GETDETKEY FAIL',     'us_english', 733
execute rdt.rdtAddMsg 53952, 10, '53952^ADD CCDET FAIL',     'us_english', 733
execute rdt.rdtAddMsg 53953, 10, '53953^UPD CCDET FAIL',     'us_english', 733
execute rdt.rdtAddMsg 53954, 10, '53954^UPD CCDET FAIL',     'us_english', 733