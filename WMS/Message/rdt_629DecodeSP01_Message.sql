-- 254051 - 254100
--rdt_629DecodeSP01  (BHA212)
execute rdt.rdtdropmsg 254051   , 254100  
 
execute rdt.rdtAddMsg 254051, 10, '254051^InvFormat',       'us_english',629, 0, '254051: Invalid format'
execute rdt.rdtAddMsg 254052, 10, '254052^DecodeFailure',   'us_english',629, 0, '254052: Fail to decode QRCode'
execute rdt.rdtAddMsg 254053, 10, '254053^InvalidDate',     'us_english',629, 0, '254053: Invalid date format'
execute rdt.rdtAddMsg 254054, 10, '254054^ConvDateFail',    'us_english',629, 0, '254054: Fail to convert date'
execute rdt.rdtAddMsg 254055, 10, '254055^InvalidSKU',      'us_english',629, 0, '254055: Invalid SKU'
 
select * from rdt.rdtmsg (nolock) where message_id between 254051 and 254100