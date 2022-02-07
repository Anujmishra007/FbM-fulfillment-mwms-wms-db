--rdt_608RcvCfm09
execute rdt.rdtDropMsg 153101 , 153150

execute rdt.rdtAddMsg 153101, 10, '53101^UPD RCPTD FAIL', 'us_english', 608
execute rdt.rdtAddMsg 153102, 10, '53102^UPD RCPTD FAIL', 'us_english', 608
execute rdt.rdtAddMsg 153103, 10, '53103^UPD RCPTD FAIL', 'us_english', 608
execute rdt.rdtAddMsg 153104, 10, '53104^UPD RCPTD FAIL', 'us_english', 608

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 153101 AND 153150
