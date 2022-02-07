--rdt_608RcvCfm07
rdt.rdtDropMsg 142901 , 142950

execute rdt.rdtAddMsg 142901, 10, '42901^SerialNotExist',   'us_english', 608
execute rdt.rdtAddMsg 142902, 10, '42902^Upd UDF01 Fail',   'us_english', 608

--WMS-11627
execute rdt.rdtAddMsg 142903, 10, '42903^Upd UDF01 Fail',   'us_english', 608

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 142901 AND 142950