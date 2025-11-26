--rdt_1856CaptureInf02
-- FCR-8525
rdt.rdtDropMsg 252051 , 252100

execute rdt.rdtAddMsg 252051, 10, '252051 RunSQLFail',                  'us_english', 1856, 0, '252051 Run SQL Script Failed'
execute rdt.rdtAddMsg 252052, 10, '252052 Need Data',                   'us_english', 1856, 0, '252052 Data is required'
execute rdt.rdtAddMsg 252053, 10, '252053 UpdPkdFail',                  'us_english', 1856, 0, '252053 Update PickDetail Failed'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 252051 AND 252100