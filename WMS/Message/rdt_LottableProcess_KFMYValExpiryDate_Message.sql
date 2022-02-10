--rdt_LottableProcess_KFMYValExpiryDate
execute rdt.rdtDropMsg 154051 , 154100

execute rdt.rdtAddMsg 154051, 10, '54051^Lottable04 req',   'us_english', 600
execute rdt.rdtAddMsg 154052, 10, '54052^Inv ExpiryDate',   'us_english', 600


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 154051 AND 154100
