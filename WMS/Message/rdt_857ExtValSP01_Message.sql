--rdt_857ExtUpdSP03
rdt.rdtDropMsg 160301, 160350

execute rdt.rdtAddMsg 160301, 10, '160301^InvalidApptNo',   'us_english', 857
execute rdt.rdtAddMsg 160302, 10, '160302^EarlyArrival',   'us_english', 857
execute rdt.rdtAddMsg 160303, 10, '160303LoadingNotDone',   'us_english', 857
execute rdt.rdtAddMsg 160304, 10, '160304^CheckInFail',   'us_english', 857
execute rdt.rdtAddMsg 160305, 10, '160305UpdBookingFail',   'us_english', 857


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 160301 AND 160350