--rdt_LottableProcess_MDLGenL4ByL13
execute rdt.rdtDropMsg 149101 , 149150

execute rdt.rdtAddMsg 149101, 10, '49101^Inv ShelfLife',    'us_english', 600

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 149101 AND 149150
