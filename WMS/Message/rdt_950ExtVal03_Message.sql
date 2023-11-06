-- rdt_950ExtVal03
execute rdt.rdtdropmsg 208051, 208100

execute rdt.rdtAddMsg 208051, 10, '208051^ValidationERR',    'us_english', 950
execute rdt.rdtAddMsg 208052, 10, '208052^Invalid Input',    'us_english', 950


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 208051 AND 208100
