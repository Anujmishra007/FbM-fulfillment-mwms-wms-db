--rdt_TM_Assist_ClusterPick_ConfirmPick
rdt.rdtDropMsg 171951 , 172000

execute rdt.rdtAddMsg 171951, 10, '171951Pick Not Found',   'us_english', 1855
execute rdt.rdtAddMsg 171952, 10, '171952 No PickSlip  ',   'us_english', 1855
execute rdt.rdtAddMsg 171953, 10, '171953UPD PKDtl Fail',   'us_english', 1855
execute rdt.rdtAddMsg 171954, 10, '171954UPD PKDtl Fail',   'us_english', 1855
execute rdt.rdtAddMsg 171955, 10, '171955UPD PKDtl Fail',   'us_english', 1855
execute rdt.rdtAddMsg 171956, 10, '171956 nspg_GetKey  ',   'us_english', 1855
execute rdt.rdtAddMsg 171957, 10, '171957INS PKDtl Fail',   'us_english', 1855
execute rdt.rdtAddMsg 171958, 10, '171958INS RefKeyFail',   'us_english', 1855
execute rdt.rdtAddMsg 171959, 10, '171959UPD PKDtl Fail',   'us_english', 1855
execute rdt.rdtAddMsg 171960, 10, '171960UPD PKDtl Fail',   'us_english', 1855
execute rdt.rdtAddMsg 171961, 10, '171961UPD PKDtl Fail',   'us_english', 1855
execute rdt.rdtAddMsg 171962, 10, '171962UPD Task  Fail',   'us_english', 1855
execute rdt.rdtAddMsg 171963, 10, '171963UPD Task  Fail',   'us_english', 1855
execute rdt.rdtAddMsg 171964, 10, '171964UPD Task  Fail',   'us_english', 1855

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 171951 AND 172000