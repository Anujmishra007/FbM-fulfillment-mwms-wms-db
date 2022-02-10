--rdt_LottableProcess_GenLot04_EAT01
execute rdt.rdtDropMsg 150151 , 150200

execute rdt.rdtAddMsg 150151, 10, '50151^Invalid Month',   'us_english', 598

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 150151 AND 150200
