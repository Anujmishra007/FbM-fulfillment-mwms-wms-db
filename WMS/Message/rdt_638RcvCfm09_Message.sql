-- rdt_638RcvCfm09
execute rdt.rdtDropMsg 170351  , 170400	

execute rdt.rdtAddMsg 170351, 10, '170351UpdRDFail', 'us_english', 638
execute rdt.rdtAddMsg 170352, 10, '170352InsRDFail', 'us_english', 638
execute rdt.rdtAddMsg 170353, 10, '170353UpdRDFail', 'us_english', 638


SELECT TOP 10 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 170351 and 170400
