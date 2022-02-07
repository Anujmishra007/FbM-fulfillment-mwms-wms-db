--rdtfnc_WorkOrder_StartLine
execute rdt.rdtdropmsg 58051 , 58100

execute rdt.rdtAddMsg 58051, 10, '58051^WRKSTATION REQ',    'us_english', 1150
execute rdt.rdtAddMsg 58052, 10, '58052^INV WRKSTATION',    'us_english', 1150
execute rdt.rdtAddMsg 58054, 10, '58054^INV JOB ID',        'us_english', 1150
execute rdt.rdtAddMsg 58057, 10, '58057^INV WORKORDER#',    'us_english', 1150

execute rdt.rdtAddMsg 58060, 10, '58060^OPTION REQUIRE',    'us_english', 1150
execute rdt.rdtAddMsg 58061, 10, '58061^INVALID OPTION',    'us_english', 1150
execute rdt.rdtAddMsg 58062, 10, '58062^INS WKLOG FAIL',    'us_english', 1150
execute rdt.rdtAddMsg 58063, 10, '58063^UPD WKSTN FAIL',    'us_english', 1150

-- Long Msg (Msg queue)
--58053 EITHER JOB ID OR WORKORDER#
--58055 JOB ID CONTAIN > 1 WORKORDER#. KEY IN BOTH VALUE TO PROCEED
--58056 INVALID JOB ID + WORKORDER#
--58058 WORKORDER# CONTAIN > 1 JOB ID. KEY IN BOTH VALUE TO PROCEED
--58059 INVALID JOB ID + WORKORDER#