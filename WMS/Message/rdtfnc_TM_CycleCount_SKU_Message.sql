
-- rdtfnc_TM_CycleCount_SKU_Message 74501 - 74550

--execute rdt.rdtdropmsg 74501, 74550
-- **********************************************



execute rdt.rdtAddMsg 74501 ,10, '74501^SKU Req', 'us_english'
execute rdt.rdtAddMsg 74502 ,10, '74502^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 74503 ,10, '74503^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 74504 ,10, '74504^Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 74505 ,10, '74505^Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 74506 ,10, '74506^Option needed', 'us_english'
execute rdt.rdtAddMsg 74507 ,10, '74507^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 74508 ,10, '74508^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74509 ,10, '74509^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74510 ,10, '74510^UpdTaskDetFailed', 'us_english'
execute rdt.rdtAddMsg 74511 ,10, '74511^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74512 ,10, '74512^UpdTaskDetFailed', 'us_english'
execute rdt.rdtAddMsg 74513 ,10, '74513^UPDCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74514 ,10, '74514^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 74515 ,10, '74515^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 74516 ,10, '74516^No More Task!', 'us_english'
execute rdt.rdtAddMsg 74517 ,10, '74517^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 74518 ,10, '74518^Qty Req', 'us_english'
execute rdt.rdtAddMsg 74519 ,10, '74519^Qty Req', 'us_english'
execute rdt.rdtAddMsg 74520 ,10, '74520^Lottable01 required', 'us_english'
execute rdt.rdtAddMsg 74521 ,10, '74521^Lottable02 required', 'us_english'
execute rdt.rdtAddMsg 74522 ,10, '74522^Lottable03 required', 'us_english'
execute rdt.rdtAddMsg 74523 ,10, '74523^Lottable04 required', 'us_english'
execute rdt.rdtAddMsg 74524 ,10, '74524^CCPostingFail', 'us_english'
execute rdt.rdtAddMsg 74525 ,10, '74525^InvalidStorer', 'us_english'
execute rdt.rdtAddMsg 74526 ,10, '74526^DuplicateLottable', 'us_english'
execute rdt.rdtAddMsg 74527 ,10, '74527^InvLottable03', 'us_english'
execute rdt.rdtAddMsg 74528 ,10, '74528^MixCountTypeNotAllowed', 'us_english'

--SOS257258
execute rdt.rdtAddMsg 74529 ,10, '74529^UPD ALERT FAIL', 'us_english'
execute rdt.rdtAddMsg 74530 ,10, '74530^UpdTaskDetFail', 'us_english'

--SOS350672
execute rdt.rdtAddMsg 74531 ,10, '74531^Invalid Storer', 'us_english'
execute rdt.rdtAddMsg 74532 ,10, '74532^Invalid SKU', 'us_english'

--WMS-16634
execute rdt.rdtAddMsg 74533 ,10, '74533^Option needed', 'us_english'
execute rdt.rdtAddMsg 74534 ,10, '74534^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 74535 ,10, '74535^Upd LastCC Err', 'us_english'

Update rdt.rdtmsg set Func = 1768 Where Message_ID Between  74501 AND 74550







