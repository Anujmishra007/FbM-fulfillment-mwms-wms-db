
-- rdt_AT_HaulerCheckIN
execute rdt.rdtDropMsg 185051 , 185100

execute rdt.rdtAddMsg 185051 ,10, '185051InvApptNo', 'us_english', 652
execute rdt.rdtAddMsg 185052, 10, '185052InvStatus', 'us_english', 652
execute rdt.rdtAddMsg 185053, 10, '185053UpdBOFail', 'us_english', 652
execute rdt.rdtAddMsg 185054, 10, '185054InsBEFail', 'us_english', 652

