-- rdt_600RcvCfm12
execute rdt.rdtDropMsg 177601, 177650

execute rdt.rdtAddMsg 177601, 10, '177601^UpdUccFail   ', 'us_english', 600


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 177601 AND 177650