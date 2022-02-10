--rdt_1841ClosePlt01
exec rdt.rdtDropMsg 148101 , 148150

execute rdt.rdtAddMsg 148101, 10, '48101^No PALoc Found',   'us_english', 1841
execute rdt.rdtAddMsg 148102, 10, '48102^Ins LOG Fail',     'us_english', 1841
execute rdt.rdtAddMsg 148103, 10, '48103^CreatePATaskEr',   'us_english', 1841
execute rdt.rdtAddMsg 148104, 10, '48104^Close Plt Fail',   'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 148101 AND 148150


