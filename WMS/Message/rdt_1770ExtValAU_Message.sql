--269301 - 269350

execute rdt.rdtdropmsg 269301, 269350

execute rdt.rdtAddMsg 269301, 10, '269301^Need DropID',  'us_english', 1770
execute rdt.rdtAddMsg 269302, 10, '269302^Diff lane',    'us_english', 1770
execute rdt.rdtAddMsg 269303, 10, '269303^Diff Shipper', 'us_english', 1770
execute rdt.rdtAddMsg 269304, 10, '269304^Diff Wave',    'us_english', 1770

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 269301 AND 269350