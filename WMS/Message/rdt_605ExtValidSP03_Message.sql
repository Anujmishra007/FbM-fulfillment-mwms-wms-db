-- rdt_605ExtValidSP03
-- 255401 - 255450

exec rdt.rdtdropmsg 255401, 255450

execute rdt.rdtAddMsg 255401, 10, '255401^NoSNFounhd',      'us_english', 605, 0, '255401 No SerialNo Data'
execute rdt.rdtAddMsg 255402, 10, '255402^SNQtyNotTally',   'us_english', 605, 0, '255402 Sum of SN Qty not match with ASN Qty'
execute rdt.rdtAddMsg 255403, 10, '255403^InvalidLot02',    'us_english', 605, 0, '255403 Invalid Lottable02 format'
execute rdt.rdtAddMsg 255404, 10, '255404^InvalidLot02',    'us_english', 605, 0, '255404 Invalid Lottable02 format'
execute rdt.rdtAddMsg 255405, 10, '255405^InvalidSUSR4',    'us_english', 605, 0, '255405 SUSR4 must be numeric'
execute rdt.rdtAddMsg 255406, 10, '255406^ExceedDOTRange',  'us_english', 605, 0, '255406 Excceed the DOT range'

select * from rdt.rdtmsg with (nolock) where message_id between 255401 and 255450