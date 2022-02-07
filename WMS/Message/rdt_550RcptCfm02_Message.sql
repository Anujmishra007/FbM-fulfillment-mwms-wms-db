--rdt_550RcptCfm02
execute rdt.rdtDropMsg 134851, 134900

execute rdt.rdtAddMsg 134851, 10, '34851^RcptCfm Fail',     'us_english', 550

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 134851 AND 134900

