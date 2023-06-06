-- rdt_600DecodeSP09
execute rdt.rdtDropMsg 166201, 166250

execute rdt.rdtAddMsg 166201, 10, '166201^Require SKU', 'us_english', 600
execute rdt.rdtAddMsg 166202, 10, '166202^Require L02', 'us_english', 600
execute rdt.rdtAddMsg 166203, 10, '166203^Require L13', 'us_english', 600
execute rdt.rdtAddMsg 166204, 10, '166204^Require L04', 'us_english', 600
execute rdt.rdtAddMsg 166205, 10, '166205^Invalid SKU', 'us_english', 600
execute rdt.rdtAddMsg 166206, 10, '166206^Invalid L02', 'us_english', 600
execute rdt.rdtAddMsg 166207, 10, '166207^Invalid L13', 'us_english', 600
execute rdt.rdtAddMsg 166208, 10, '166208^Invalid L04', 'us_english', 600



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 166201 AND 166250