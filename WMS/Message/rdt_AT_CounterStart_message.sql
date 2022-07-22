

-- rdt_AT_CounterStart
execute rdt.rdtDropMsg 185101   , 185150

execute rdt.rdtAddMsg 185101 ,10, '185101InvApptNo', 'us_english', 652
execute rdt.rdtAddMsg 185102, 10, '185102InvStatus', 'us_english', 652
execute rdt.rdtAddMsg 185103, 10, '185103UpdBOFail', 'us_english', 652
execute rdt.rdtAddMsg 185104, 10, '185104InsBEFail', 'us_english', 652
   