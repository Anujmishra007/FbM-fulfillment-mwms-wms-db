--rdt_TrackNo_SortToPallet_GetMbolKey
rdt.rdtDropMsg 174151 , 174200	

execute rdt.rdtAddMsg 174151, 10, '174151 OrdersShipped',    'us_english', 1653

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 174151 AND 174200