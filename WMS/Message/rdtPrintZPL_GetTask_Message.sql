-- rdtPrintZPL_GetTask
execute rdt.rdtDropMsg 120151, 120200

execute rdt.rdtAddMsg 120151, 10, '120151JobIDNotFound ', 'us_english'
execute rdt.rdtAddMsg 120152, 10, '120151ReportNotFound', 'us_english'
execute rdt.rdtAddMsg 120153, 10, '120152Setup Printer ', 'us_english'
execute rdt.rdtAddMsg 120154, 10, '120153Invalid SP    ', 'us_english'
