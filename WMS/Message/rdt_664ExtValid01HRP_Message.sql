execute rdt.rdtdropmsg 218372,218376

execute rdt.rdtAddMsg 218372, 10, '218372 LOC in use',  'us_english', 664
execute rdt.rdtAddMsg 218373, 10, '218373 LOC Allocated on ASN',  'us_english', 664
execute rdt.rdtAddMsg 218374, 10, '218374 Different SKU in PICK location',  'us_english', 664
execute rdt.rdtAddMsg 218375, 10, '218375 Non-Dedicated pallet',  'us_english', 664
execute rdt.rdtAddMsg 218376, 10, '218376 Dedicated pallet',  'us_english', 664



select * from rdt.rdtmsg (nolock) where message_id  between 218372 and 218376
