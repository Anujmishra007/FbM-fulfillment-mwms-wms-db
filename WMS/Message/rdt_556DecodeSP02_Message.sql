--rdt_556DecodeSP02  (SSR259)
-- 253901 - 253950
 
execute rdt.rdtdropmsg 253901   , 253950    
 
execute rdt.rdtAddMsg 253901, 10, '253901^InvFormat',       'us_english',556, 0, '253901: Invalid format'
execute rdt.rdtAddMsg 253902, 10, '253902^DecodeFailure',   'us_english',556, 0, '253902: Fail to decode QRCode'
execute rdt.rdtAddMsg 253903, 10, '253903^InvalidDate',     'us_english',556, 0, '253903: Invalid date format'
execute rdt.rdtAddMsg 253904, 10, '253904^ConvDateFail',    'us_english',556, 0, '253904: Fail to convert date'
execute rdt.rdtAddMsg 253905, 10, '253905^InvalidSKU',      'us_english',556, 0, '253905: Invalid SKU'
select * from rdt.rdtmsg (nolock) where message_id between 253901 and 253950
 