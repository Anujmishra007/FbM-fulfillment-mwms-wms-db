-- rdt_1581RcptCfm02
exec rdt.rdtDropMsg 113851 , 113900

execute rdt.rdtAddMsg 113851, 10, '13851^No Line To Rcv',   'us_english', 1581

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 113851 AND 113900