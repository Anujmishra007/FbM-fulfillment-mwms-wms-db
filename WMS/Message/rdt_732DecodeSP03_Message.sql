--rdt_732DecodeSP03
execute rdt.rdtdropmsg 144951 , 145000

execute rdt.rdtAddMsg 144951, 10, '44951^SKU Inactive',   'us_english', 732

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 144951 AND 145000	