--rdt_555DecodeSP02  (NYE018)
--253851 - 253900

execute rdt.rdtdropmsg 253851   , 253900	

execute rdt.rdtAddMsg 253851, 10, '253851^InvFormat',       'us_english',555, 0, '253851: Invalid format'
execute rdt.rdtAddMsg 253852, 10, '253852^DecodeFailure',   'us_english',555, 0, '253852: Fail to decode QRCode'
execute rdt.rdtAddMsg 253853, 10, '253853^InvalidDate',     'us_english',555, 0, '253853: Invalid date format'
execute rdt.rdtAddMsg 253854, 10, '253854^ConvDateFail',    'us_english',555, 0, '253854: Fail to convert date'
execute rdt.rdtAddMsg 253855, 10, '253855^InvalidSKU',      'us_english',555, 0, '253855: Invalid SKU'

select * from rdt.rdtmsg (nolock) where message_id between 253851 and 253900