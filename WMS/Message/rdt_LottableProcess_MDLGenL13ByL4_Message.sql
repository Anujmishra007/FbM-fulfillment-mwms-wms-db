--rdt_LottableProcess_MDLGenL13ByL4
execute rdt.rdtDropMsg 149151 , 149200

execute rdt.rdtAddMsg 149151, 10, '49151^Inv ShelfLife',    'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 149151 AND 149200
