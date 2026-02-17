-- 254801 - 254850
--rdt_830DecodeSP09  (BHA212)
execute rdt.rdtdropmsg 254801   , 254850
 
execute rdt.rdtAddMsg 254801, 10, '254801^InvFormat',       'us_english',830, 0, '254801: Invalid format'
execute rdt.rdtAddMsg 254802, 10, '254802^DecodeFailure',   'us_english',830, 0, '254802: Fail to decode QRCode'
execute rdt.rdtAddMsg 254803, 10, '254803^InvalidDate',     'us_english',830, 0, '254803: Invalid date format'
execute rdt.rdtAddMsg 254804, 10, '254804^ConvDateFail',    'us_english',830, 0, '254804: Fail to convert date'
execute rdt.rdtAddMsg 254805, 10, '254805^InvalidSKU',      'us_english',830, 0, '254805: Invalid SKU'
 
select * from rdt.rdtmsg (nolock) where message_id between 254801 and 254850