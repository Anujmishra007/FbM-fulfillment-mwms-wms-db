--rdt_838DecodeSP17  (NYE018)
--254751 - 254800

execute rdt.rdtdropmsg 254751   , 254800	

execute rdt.rdtAddMsg 254751, 10, '254751^InvFormat',       'us_english',838, 0, '254751: Invalid format'
execute rdt.rdtAddMsg 254752, 10, '254752^DecodeFailure',   'us_english',838, 0, '254752: Fail to decode QRCode'
execute rdt.rdtAddMsg 254753, 10, '254753^InvalidSKU',      'us_english',838, 0, '254753: Invalid SKU'

select * from rdt.rdtmsg (nolock) where message_id between 254751 and 254800