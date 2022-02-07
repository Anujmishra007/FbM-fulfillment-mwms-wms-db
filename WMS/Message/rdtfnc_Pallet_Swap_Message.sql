--rdtfnc_Pallet_Swap
execute rdt.rdtdropmsg 53551 , 53600

execute rdt.rdtAddMsg '53551', 10, '53551^FROM ID REQ',     'us_english'
execute rdt.rdtAddMsg '53552', 10, '53552^INVALID ID',      'us_english'
execute rdt.rdtAddMsg '53553', 10, '53553^TO ID REQ',       'us_english'
execute rdt.rdtAddMsg '53554', 10, '53554^ID mix storer',   'us_english'
execute rdt.rdtAddMsg '53555', 10, '53555^NotInStorerGrp',  'us_english'
