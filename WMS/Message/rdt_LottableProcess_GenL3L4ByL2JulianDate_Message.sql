--rdt_LottableProcess_GenL3L4ByL2JulianDate
execute rdt.rdtDropMsg 142001 , 142050

execute rdt.rdtAddMsg 142001, 10, '42001^Inv Batch/Year',   'us_english', 607
execute rdt.rdtAddMsg 142002, 10, '42002^Inv DaysInYear',   'us_english', 607
execute rdt.rdtAddMsg 142003, 10, '42003^DaysInYear <=0',   'us_english', 607
execute rdt.rdtAddMsg 142004, 10, '42004^DaysInYear>366',   'us_english', 607
execute rdt.rdtAddMsg 142005, 10, '42005^DaysInYear>365',   'us_english', 607


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID  BETWEEN 142001 AND 142050
