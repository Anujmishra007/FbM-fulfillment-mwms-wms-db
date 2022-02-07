--rdt_ReceiptReversal_Confirm
execute rdt.rdtdropmsg 55851 , 55900

execute rdt.rdtAddMsg 55851, 10, '55851^INVALID OPTION',        'us_english'
execute rdt.rdtAddMsg 55852, 10, '55852^INVALID PLT ID',        'us_english'
execute rdt.rdtAddMsg 55853, 10, '55853^INVALID SKU',           'us_english'
execute rdt.rdtAddMsg 55854, 10, '55854^TL3 REC EXISTS',        'us_english'
execute rdt.rdtAddMsg 55855, 10, '55854^REV RCVDT FAIL',        'us_english'
execute rdt.rdtAddMsg 55856, 10, '55855^REV RCVHD FAIL',        'us_english'
execute rdt.rdtAddMsg 55857, 10, '55857^REV PODTL FAIL',        'us_english'
