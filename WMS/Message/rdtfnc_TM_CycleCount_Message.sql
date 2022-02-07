-- rdtfnc_TM_CycleCount 
execute rdt.rdtdropmsg 74401, 74450
execute rdt.rdtdropmsg 57951, 58000

/**********************************************/
execute rdt.rdtAddMsg 74401 ,10, '74401^Loc req', 'us_english'
execute rdt.rdtAddMsg 74402 ,10, '74402^Invalid Loc', 'us_english'
execute rdt.rdtAddMsg 74403 ,10, '74403^UpdTaskFailed', 'us_english'
execute rdt.rdtAddMsg 74404 ,10, '74404^Invalid ID', 'us_english'
execute rdt.rdtAddMsg 74405 ,10, '74405^Option Req', 'us_english'
execute rdt.rdtAddMsg 74406 ,10, '74406^Reason Req', 'us_english'
execute rdt.rdtAddMsg 74407 ,10, '74407^UpdTaskdetFail', 'us_english'
execute rdt.rdtAddMsg 74408 ,10, '74408^UpdTaskdetFail', 'us_english'
execute rdt.rdtAddMsg 74409 ,10, '74409^NextTaskFncErr', 'us_english'
execute rdt.rdtAddMsg 74410 ,10, '74410^NextTaskFncErr', 'us_english'
execute rdt.rdtAddMsg 74411 ,10, '74411^NextTaskFncErr', 'us_english'
execute rdt.rdtAddMsg 74412 ,10, '74412^NextTaskFncErr', 'us_english'
execute rdt.rdtAddMsg 74413 ,10, '74413^NextTaskFncErr', 'us_english'
execute rdt.rdtAddMsg 74414 ,10, '74414^Inv Option', 'us_english'
execute rdt.rdtAddMsg 74415 ,10, '74415^UPDTaskDetFail', 'us_english'
execute rdt.rdtAddMsg 74416 ,10, '74416^Option Req', 'us_english'
execute rdt.rdtAddMsg 74417 ,10, '74417^Inv Option', 'us_english'
execute rdt.rdtAddMsg 74418 ,10, '74418^GetKey Fail', 'us_english'
execute rdt.rdtAddMsg 74419 ,10, '74419^GetKey Fail', 'us_english'
execute rdt.rdtAddMsg 74420 ,10, '74420^InsCCLockFail', 'us_english'
execute rdt.rdtAddMsg 74421 ,10, '74421^GetKey Fail', 'us_english'
execute rdt.rdtAddMsg 74422 ,10, '74422^GetKey Fail', 'us_english'
execute rdt.rdtAddMsg 74423 ,10, '74423^InsCCLockFail', 'us_english'
execute rdt.rdtAddMsg 74424 ,10, '74424^UPDTaskDetFail', 'us_english'
execute rdt.rdtAddMsg 74425 ,10, '74425^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74426 ,10, '74426^UPDTaskDetFail', 'us_english'
execute rdt.rdtAddMsg 74427 ,10, '74427^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74428 ,10, '74428^UPDTaskDetFail', 'us_english'
execute rdt.rdtAddMsg 74429 ,10, '74429^NextTaskFncErr', 'us_english'
execute rdt.rdtAddMsg 74430 ,10, '74430^NextTaskScnErr', 'us_english'
execute rdt.rdtAddMsg 74431 ,10, '74431^Invalid UCC', 'us_english'

execute rdt.rdtAddMsg 74432 ,10, '74432^Invalid Loc', 'us_english'
execute rdt.rdtAddMsg 74433 ,10, '74433^UPDTaskDetFail', 'us_english'
execute rdt.rdtAddMsg 74434 ,10, '74434^Task Taken!', 'us_english'

execute rdt.rdtAddMsg 74435 ,10, '74435^Option needed', 'us_english'
execute rdt.rdtAddMsg 74436 ,10, '74436^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 74437 ,10, '74437^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74438 ,10, '74438^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74439 ,10, '74439^UpdTaskDetFailed', 'us_english'
execute rdt.rdtAddMsg 74440 ,10, '74440^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74441 ,10, '74441^UpdTaskDetFailed', 'us_english'
execute rdt.rdtAddMsg 74442 ,10, '74442^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74443 ,10, '74443^InsCCDetFail', 'us_english'

--SOS257258
execute rdt.rdtAddMsg 74444 ,10, '74444^LOC IS LOSEUCC', 'us_english'
execute rdt.rdtAddMsg 74445 ,10, '74445^LOC X LOSEUCC',  'us_english'
execute rdt.rdtAddMsg 74446 ,10, '74446^LOC X LOSEUCC',  'us_english'

--SOS316401
execute rdt.rdtAddMsg 74447, 10, '74447^Plt ID Req',      'us_english'
execute rdt.rdtAddMsg 74448, 10, '74448^Invalid Plt ID',  'us_english'
execute rdt.rdtAddMsg 74449 ,10, '74449^LOC X LOSEUCC',  'us_english'
execute rdt.rdtAddMsg 74450 ,10, '74450^LOC X LOSEUCC',  'us_english'

--SOS350672
execute rdt.rdtAddMsg 57951, 10, '57951^InsSkipTskFail',  'us_english'
execute rdt.rdtAddMsg 57952, 10, '57952^UpdTaskdetFail',  'us_english'

--WMS-16634
execute rdt.rdtAddMsg 57953, 10, '57953^Upd LastCC Err',  'us_english'

Update rdt.rdtmsg set Func = 1766 Where Message_ID Between  74401 AND 74450
Update rdt.rdtmsg set Func = 1766 Where Message_ID Between  57951 AND 58000








