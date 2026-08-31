--rdt_664ExtValid01HRP
--218372 - 218376

execute rdt.rdtdropmsg 218372,218376

execute rdt.rdtAddMsg 218372, 10, '218372 LOC in use',  'us_english', 664
execute rdt.rdtAddMsg 218373, 10, '218373 LOC Allocated on ASN',  'us_english', 664
execute rdt.rdtAddMsg 218374, 10, '218374 Different SKU in PICK location',  'us_english', 664
execute rdt.rdtAddMsg 218375, 10, '218375 Non-Dedicated pallet',  'us_english', 664
execute rdt.rdtAddMsg 218376, 10, '218376 Dedicated pallet',  'us_english', 664

select * from rdt.rdtmsg (nolock) where message_id  between 218372 and 218376

--V1.2
--267851 - 267900

execute rdt.rdtdropmsg 267851,267900

execute rdt.rdtAddMsg 267851, 10, '267851 Invalid non-dedicated allocation (rdt_664ExtValid01HRP)', 'us_english', 664, 0, ''
execute rdt.rdtAddMsg 267852, 10, '267852 Invalid dedicated allocation (rdt_664ExtValid01HRP)', 'us_english', 664, 0, ''

select * from rdt.rdtmsg (nolock) where message_id  between 267851 and 267900



