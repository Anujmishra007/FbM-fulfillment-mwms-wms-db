--rdtfnc_SortationByTrackingID_Reversal
rdt.rdtDropMsg 149501 , 149550

execute rdt.rdtAddMsg 149501, 10, '49501^Value req',        'us_english', 642
execute rdt.rdtAddMsg 149502, 10, '49502^Invalid Format',   'us_english', 642
execute rdt.rdtAddMsg 149503, 10, '49503^PalletNotExist',   'us_english', 642
execute rdt.rdtAddMsg 149504, 10, '49504^Need SKU/UPC',     'us_english', 642
execute rdt.rdtAddMsg 149505, 10, '49505^Invalid SKU',      'us_english', 642
execute rdt.rdtAddMsg 149506, 10, '49506^MultiBarcodSKU',   'us_english', 642
execute rdt.rdtAddMsg 149507, 10, '49507^Need Track ID',    'us_english', 642
execute rdt.rdtAddMsg 149508, 10, '49508^Invalid Format',   'us_english', 642
execute rdt.rdtAddMsg 149509, 10, '49509^ID Not Exist',     'us_english', 642
execute rdt.rdtAddMsg 149510, 10, '49510^OptionRequired',   'us_english', 642
execute rdt.rdtAddMsg 149511, 10, '49511^Invalid Option',   'us_english', 642
execute rdt.rdtAddMsg 149512, 10, '49512^SKU NOT EXISTS',   'us_english', 642
execute rdt.rdtAddMsg 149513, 10, '49513^Pallet Closed',    'us_english', 642




SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 149501 AND 149550