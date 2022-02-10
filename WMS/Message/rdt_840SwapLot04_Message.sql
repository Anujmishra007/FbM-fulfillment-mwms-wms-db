--rdt_840SwapLot04
EXEC rdt.rdtDropMsg 169701 , 169750

execute rdt.rdtAddMsg 169701, 10, '169701 INVALID ORDER', 'us_english', 840
execute rdt.rdtAddMsg 169702, 10, '169702 INVALID SKU  ', 'us_english', 840
execute rdt.rdtAddMsg 169703, 10, '169703 INVALID LOT02', 'us_english', 840
execute rdt.rdtAddMsg 169704, 10, '169704SKU NOT IN ORD', 'us_english', 840
execute rdt.rdtAddMsg 169705, 10, '169705 INVALID LABEL', 'us_english', 840
execute rdt.rdtAddMsg 169706, 10, '169706 DIFF HM ORDER', 'us_english', 840
execute rdt.rdtAddMsg 169707, 10, '169707SKU OVERPACKED', 'us_english', 840
execute rdt.rdtAddMsg 169708, 10, '169708 QtyMoved Fail', 'us_english', 840
execute rdt.rdtAddMsg 169709, 10, '169709 SWAP LOT FAIL', 'us_english', 840
execute rdt.rdtAddMsg 169710, 10, '169710 SWAP LOT FAIL', 'us_english', 840
execute rdt.rdtAddMsg 169711, 10, '169711 SWAP LOT FAIL', 'us_english', 840
execute rdt.rdtAddMsg 169712, 10, '169712 SWAP LOT FAIL', 'us_english', 840
execute rdt.rdtAddMsg 169713, 10, '169713 UPDPKDET Fail', 'us_english', 840
execute rdt.rdtAddMsg 169714, 10, '169714 SWAP LOT FAIL', 'us_english', 840
execute rdt.rdtAddMsg 169715, 10, '169715 SWAP LOT FAIL', 'us_english', 840
execute rdt.rdtAddMsg 169716, 10, '169716 UpdLog Failed', 'us_english', 840
execute rdt.rdtAddMsg 169717, 10, '169717 InsLog Failed', 'us_english', 840
execute rdt.rdtAddMsg 169718, 10, '169718 InsPKHDR Fail', 'us_english', 840
execute rdt.rdtAddMsg 169719, 10, '169719 UPDPKDET Fail', 'us_english', 840
execute rdt.rdtAddMsg 169720, 10, '169720GET LABEL Fail', 'us_english', 840
execute rdt.rdtAddMsg 169721, 10, '169721 INSPKDET Fail', 'us_english', 840
execute rdt.rdtAddMsg 169722, 10, '169722 INSPKDET Fail', 'us_english', 840
execute rdt.rdtAddMsg 169723, 10, '169723UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 169724, 10, '169724UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 169725, 10, '169725UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 169726, 10, '169726 GetKey Fail',   'us_english', 840
execute rdt.rdtAddMsg 169727, 10, '169727INS PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 169728, 10, '169728INS RefKeyFail', 'us_english', 840
execute rdt.rdtAddMsg 169729, 10, '169729UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 169730, 10, '169730UPD PKDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 169731, 10, '169731 OFFSET ERROR ', 'us_english', 840
execute rdt.rdtAddMsg 169732, 10, '169732 Upd Case Fail', 'us_english', 840
execute rdt.rdtAddMsg 169733, 10, '169733 Upd Case Fail', 'us_english', 840
execute rdt.rdtAddMsg 169734, 10, '169734 GetKey Fail  ', 'us_english', 840
execute rdt.rdtAddMsg 169735, 10, '169735 Ins PDtl Fail', 'us_english', 840
execute rdt.rdtAddMsg 169736, 10, '169736 Upd Case Fail', 'us_english', 840
execute rdt.rdtAddMsg 169737, 10, '169737nspGetRightErr', 'us_english', 840
execute rdt.rdtAddMsg 169738, 10, '169738 GenTLog3 Fail', 'us_english', 840
execute rdt.rdtAddMsg 169739, 10, '169739 SWAP LOT FAIL', 'us_english', 840      -- ZG01
execute rdt.rdtAddMsg 169740, 10, '169740 SWAP LOT FAIL', 'us_english', 840      -- ZG01

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 169701 AND 169750