--rdt_862PickCfm07
rdt.rdtDropMsg 202101 , 202150

execute rdt.rdtAddMsg 202101, 10, '202101 Bad TaskQTY  ',   'us_english', 862
execute rdt.rdtAddMsg 202102, 10, '202102Bad ConfirmQTY',   'us_english', 862
execute rdt.rdtAddMsg 202103, 10, '202103 Over Pick    ',   'us_english', 862
execute rdt.rdtAddMsg 202104, 10, '202104Get PKDtl Fail',   'us_english', 862
execute rdt.rdtAddMsg 202105, 10, '202105 Task Changed ',   'us_english', 862
execute rdt.rdtAddMsg 202106, 10, '202106 Task Changed ',   'us_english', 862
execute rdt.rdtAddMsg 202107, 10, '202107 Offset Error ',   'us_english', 862
execute rdt.rdtAddMsg 202108, 10, '202108Upd PKDtl Fail',   'us_english', 862
execute rdt.rdtAddMsg 202109, 10, '202109 Task Changed ',   'us_english', 862
execute rdt.rdtAddMsg 202110, 10, '202110 Upd UCC Fail ',   'us_english', 862
execute rdt.rdtAddMsg 202111, 10, '202111 Upd UCC Fail ',   'us_english', 862
execute rdt.rdtAddMsg 202112, 10, '202112 Task Changed ',   'us_english', 862
execute rdt.rdtAddMsg 202113, 10, '202113 Ins PDtl Fail',   'us_english', 862
execute rdt.rdtAddMsg 202114, 10, '202114 Upd PDtl Fail',   'us_english', 862
execute rdt.rdtAddMsg 202115, 10, '202115 Upd PDtl Fail',   'us_english', 862
execute rdt.rdtAddMsg 202116, 10, '202116 Scan Out Fail',   'us_english', 862
execute rdt.rdtAddMsg 202117, 10, '202117 Scan Out Fail',   'us_english', 862


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 202101 AND 202150