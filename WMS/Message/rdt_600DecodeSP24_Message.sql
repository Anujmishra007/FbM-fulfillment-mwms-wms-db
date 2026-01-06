
--rdt_600DecodeSP24
--248651 - 248700

execute rdt.rdtdropmsg 248651   , 248700	

execute rdt.rdtAddMsg 248651, 10, '248651^DecodeFailure',   'us_english',600, 0, '248651: Fail to decode QRCode'
execute rdt.rdtAddMsg 248652, 10, '248652^InvalidDate',     'us_english',600, 0, '248652: Invalid date format'
execute rdt.rdtAddMsg 248653, 10, '248653^ConvDateFail',    'us_english',600, 0, '248653: Fail to convert date'
execute rdt.rdtAddMsg 248654, 10, '248654^InvalidDate',     'us_english',600, 0, '248654: Invalid date format'
execute rdt.rdtAddMsg 248655, 10, '248655^ConvDateFail',    'us_english',600, 0, '248655: Fail to convert date'
execute rdt.rdtAddMsg 248656, 10, '248656^InvFormat',       'us_english',600, 0, '248656: Invalid format'


select * from rdt.rdtmsg (nolock) where message_id between 248651 and 248700	