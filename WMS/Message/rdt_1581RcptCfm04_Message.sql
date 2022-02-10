--rdt_1581RcptCfm04
 exec rdt.rdtDropMsg 115551 , 115600

execute rdt.rdtAddMsg 115551, 10, '15551^LOT01 REQUIRED',   'us_english', 1581
execute rdt.rdtAddMsg 115552, 10, '15552^UPD RDTL FAIL',    'us_english', 1581

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 115551 AND 115600
