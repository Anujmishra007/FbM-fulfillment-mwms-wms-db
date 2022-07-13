-- rdt_1641ExtValidSP17
execute rdt.rdtDropMsg 178501, 178550

execute rdt.rdtAddMsg 178501, 10, '178501^Invalid UCC  ', 'us_english', 1641
execute rdt.rdtAddMsg 178502, 10, '178502^Pack Not Done', 'us_english', 1641
execute rdt.rdtAddMsg 178503, 10, '178503^Scanned UCC  ', 'us_english', 1641
execute rdt.rdtAddMsg 178504, 10, '178504^Invalid PPA  ', 'us_english', 1641
execute rdt.rdtAddMsg 178505, 10, '178505InvalidPckInfo', 'us_english', 1641
execute rdt.rdtAddMsg 178506, 10, '178506^Diff Batch   ', 'us_english', 1641
execute rdt.rdtAddMsg 178507, 10, '178507^Diff Batch   ', 'us_english', 1641
execute rdt.rdtAddMsg 178508, 10, '178508^Diff Batch   ', 'us_english', 1641

select * from rdt.rdtmsg (nolock) where message_id between 178501 and 178550
