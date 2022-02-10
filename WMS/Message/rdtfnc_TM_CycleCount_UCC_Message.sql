
-- rdtfnc_TM_CycleCount_UCC_Message 74451 - 74500

--execute rdt.rdtdropmsg 74451 , 74500
-- **********************************************



execute rdt.rdtAddMsg 74451 ,10, '74451^Qty Required', 'us_english'
execute rdt.rdtAddMsg 74452 ,10, '74452^Invalid Qty', 'us_english'
execute rdt.rdtAddMsg 74453 ,10, '74453^InsCCFailed', 'us_english'
execute rdt.rdtAddMsg 74454 ,10, '74454^Option Req', 'us_english'
execute rdt.rdtAddMsg 74455 ,10, '74455^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 74456 ,10, '74456^DelCCFailed', 'us_english'
execute rdt.rdtAddMsg 74457 ,10, '74457^Invalid UCC', 'us_english'
execute rdt.rdtAddMsg 74458 ,10, '74458^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74459 ,10, '74459^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74460 ,10, '74460^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74461 ,10, '74461^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74462 ,10, '74462^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74463 ,10, '74463^UCC Counted', 'us_english'
execute rdt.rdtAddMsg 74464 ,10, '74464^Invalid UCC', 'us_english'

execute rdt.rdtAddMsg 74465 ,10, '74465^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74466 ,10, '74466^UpdTaskDetFailed', 'us_english'
execute rdt.rdtAddMsg 74467 ,10, '74467^No More Task!', 'us_english'
execute rdt.rdtAddMsg 74468 ,10, '74468^UpdTaskDetFailed', 'us_english'
execute rdt.rdtAddMsg 74469 ,10, '74469^CCPostingFail', 'us_english'

execute rdt.rdtAddMsg 74470 ,10, '74470^Invalid UCC', 'us_english'
execute rdt.rdtAddMsg 74471 ,10, '74471^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 74472 ,10, '74472^MixCountTypeNotAllowed', 'us_english'

--SOS257258
execute rdt.rdtAddMsg 74473 ,10, '74473^UPD ALERT FAIL', 'us_english'
execute rdt.rdtAddMsg 74474 ,10, '74474^UpdTaskDetFail', 'us_english'
execute rdt.rdtAddMsg 74475 ,10, '74475^UpdTaskDetFail', 'us_english'
execute rdt.rdtAddMsg 74476 ,10, '74476^Invalid UCC',    'us_english'

Update rdt.rdtmsg set Func = 1767 Where Message_ID Between  74451 AND 74500








