--rdt_593Print33
execute rdt.rdtdropmsg 168701, 168750

execute rdt.rdtAddMsg 168701, 10, '168701Input required', 'us_english', 593
execute rdt.rdtAddMsg 168702, 10, '168702 Printer req  ', 'us_english', 593
execute rdt.rdtAddMsg 168703, 10, '168703 Prt Group req', 'us_english', 593
execute rdt.rdtAddMsg 168704, 10, '168704ReportType req', 'us_english', 593

-- WMS-19131
execute rdt.rdtAddMsg 168705, 10, '168705Setup FilePath', 'us_english', 593
execute rdt.rdtAddMsg 168706, 10, '168706Setup FilePath', 'us_english', 593

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 168701 AND 168750