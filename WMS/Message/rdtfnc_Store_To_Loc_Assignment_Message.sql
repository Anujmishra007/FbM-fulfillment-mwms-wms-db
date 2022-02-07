--rdtfnc_Store_To_Loc_Assignment
--execute rdt.rdtdropmsg 69666, 69715

execute rdt.rdtAddMsg 69666, 10, '69666^Store Req',      'us_english'
execute rdt.rdtAddMsg 69667, 10, '69667^Invalid Store',  'us_english'
execute rdt.rdtAddMsg 69668, 10, '69668^LOC Req',        'us_english'
execute rdt.rdtAddMsg 69669, 10, '69669^Invalid TO LOC', 'us_english'
execute rdt.rdtAddMsg 69670, 10, '69670^INS Rec Fail',   'us_english'
execute rdt.rdtAddMsg 69671, 10, '69671^Option req',     'us_english'
execute rdt.rdtAddMsg 69672, 10, '69672^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 69673, 10, '69673^DEL Rec Fail',   'us_english'
execute rdt.rdtAddMsg 69674, 10, '69674^LOC UseByStore', 'us_english'
execute rdt.rdtAddMsg 69675, 10, '69675^StrHasLocAssgn', 'us_english'
execute rdt.rdtAddMsg 69676, 10, '69676^Inv LocType',    'us_english'
execute rdt.rdtAddMsg 69677, 10, '69677^PTS WITH STORE', 'us_english'
execute rdt.rdtAddMsg 69678, 10, '69678^STOREGROUP req', 'us_english'


select * from rdt.rdtmsg (nolock) where message_id between 69666 AND 69715