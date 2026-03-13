--rdt_523DecodeSP09  (SSR259)
-- 254851 - 254900
 
execute rdt.rdtdropmsg 254851   , 254900    
 
execute rdt.rdtAddMsg 254851, 10, '254851^InvFormat',       'us_english',523, 0, '254851: Invalid format'
execute rdt.rdtAddMsg 254852, 10, '254852^DecodeFailure',   'us_english',523, 0, '254852: Fail to decode QRCode'
execute rdt.rdtAddMsg 254853, 10, '254853^InvalidDate',     'us_english',523, 0, '254853: Invalid date format'
execute rdt.rdtAddMsg 254854, 10, '254854^ConvDateFail',    'us_english',523, 0, '254854: Fail to convert date'
execute rdt.rdtAddMsg 254855, 10, '254855^InvalidSKU',      'us_english',523, 0, '254855: Invalid SKU'
select * from rdt.rdtmsg (nolock) where message_id between 254851 and 254900
 