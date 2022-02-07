--rdtfnc_WCS_Pallet_Move
execute rdt.rdtdropmsg 56151 , 56200
execute rdt.rdtAddMsg 56151, 10, '56151^PALLET ID REQ',  'us_english'
execute rdt.rdtAddMsg 56152, 10, '56152^FROM LOC REQ',   'us_english'
execute rdt.rdtAddMsg 56153, 10, '56153^WRONG LOC CAT',  'us_english'
execute rdt.rdtAddMsg 56154, 10, '56154^SETUP FR FLOOR', 'us_english'
execute rdt.rdtAddMsg 56155, 10, '56155^TO LOC REQ',     'us_english'
execute rdt.rdtAddMsg 56156, 10, '56156^WRONG LOC CAT',  'us_english'
execute rdt.rdtAddMsg 56157, 10, '56157^SETUP TO FLOOR', 'us_english'
execute rdt.rdtAddMsg 56158, 10, '56158^SAME FLOOR',     'us_english'

-- SOS364967
execute rdt.rdtAddMsg 56159, 10, '56159^INVALID FORMAT', 'us_english'




