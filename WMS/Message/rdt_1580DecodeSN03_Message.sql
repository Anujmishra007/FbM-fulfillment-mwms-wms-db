--rdt_1580DecodeSN03
exec rdt.rdtDropMsg 208101, 208150

execute rdt.rdtAddMsg 208101, 10, '208101INS Log Fail  ', 'us_english', 1580
execute rdt.rdtAddMsg 208102, 10, '208102Bad SNO setup ', 'us_english', 1580
execute rdt.rdtAddMsg 208103, 10, '208103Bad SNO setup ', 'us_english', 1580
execute rdt.rdtAddMsg 208104, 10, '208104INS Log Fail  ', 'us_english', 1580