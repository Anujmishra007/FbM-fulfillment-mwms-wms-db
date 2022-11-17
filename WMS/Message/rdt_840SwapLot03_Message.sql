-- rdt_840SwapLot03
EXEC rdt.rdtDropMsg 193751 , 193800

execute rdt.rdtAddMsg 193751, 10, '193751 INVALID ORDER',   'us_english', 840
execute rdt.rdtAddMsg 193752, 10, '193752 INVALID SKU  ',   'us_english', 840
execute rdt.rdtAddMsg 193753, 10, '193753 INVALID LOT02',   'us_english', 840
execute rdt.rdtAddMsg 193754, 10, '193754SKU NOT IN ORD',   'us_english', 840
execute rdt.rdtAddMsg 193755, 10, '193755 INVALID LABEL',   'us_english', 840
execute rdt.rdtAddMsg 193756, 10, '193756 DIFF HM ORDER',   'us_english', 840
execute rdt.rdtAddMsg 193757, 10, '193757 SKU OVER PACK',   'us_english', 840
execute rdt.rdtAddMsg 193758, 10, '193758 SWAP LOT FAIL',   'us_english', 840
execute rdt.rdtAddMsg 193759, 10, '193759 SWAP LOT FAIL',   'us_english', 840
execute rdt.rdtAddMsg 193760, 10, '193760 SWAP LOT FAIL',   'us_english', 840
execute rdt.rdtAddMsg 193761, 10, '193761 SWAP LOT FAIL',   'us_english', 840
execute rdt.rdtAddMsg 193762, 10, '193762 UpdLog Failed',   'us_english', 840
execute rdt.rdtAddMsg 193763, 10, '193763 InsLog Failed',   'us_english', 840
execute rdt.rdtAddMsg 193764, 10, '193764 InsPKHDR Fail',   'us_english', 840
execute rdt.rdtAddMsg 193765, 10, '193765 UPDPKDET Fail',   'us_english', 840
execute rdt.rdtAddMsg 193766, 10, '193766 GET LABEL ERR',   'us_english', 840
execute rdt.rdtAddMsg 193767, 10, '193767 INSPKDET Fail',   'us_english', 840
execute rdt.rdtAddMsg 193768, 10, '193768 INSPKDET Fail',   'us_english', 840
execute rdt.rdtAddMsg 193769, 10, '193769 UPDPKDET Fail',   'us_english', 840
execute rdt.rdtAddMsg 193770, 10, '193770 UPD PKDtl ERR',   'us_english', 840
execute rdt.rdtAddMsg 193771, 10, '193771 UPD PKDtl ERR',   'us_english', 840
execute rdt.rdtAddMsg 193772, 10, '193772 INS PKDtl ERR',   'us_english', 840
execute rdt.rdtAddMsg 193773, 10, '193773 INS RefKeyERR',   'us_english', 840
execute rdt.rdtAddMsg 193774, 10, '193774 UPD PKDtl ERR',   'us_english', 840
execute rdt.rdtAddMsg 193775, 10, '193775 UPD PKDtl ERR',   'us_english', 840
execute rdt.rdtAddMsg 193776, 10, '193776 OFFSET ERROR  ',  'us_english', 840
execute rdt.rdtAddMsg 193777, 10, '193777 UPD PKDtl ERR ',  'us_english', 840
execute rdt.rdtAddMsg 193778, 10, '193778 nspGetRightErr',  'us_english', 840
execute rdt.rdtAddMsg 193779, 10, '193779 GenTLog3 Fail ',  'us_english', 840
execute rdt.rdtAddMsg 193780, 10, '193780 IT69 NOT MATCH',  'us_english', 840
execute rdt.rdtAddMsg 193781, 10, '193781 GET KEY FAIL  ',  'us_english', 840
execute rdt.rdtAddMsg 193782, 10, '193782 UPD CASE FAIL ',  'us_english', 840
execute rdt.rdtAddMsg 193783, 10, '193783 UPD CASE FAIL ',  'us_english', 840
execute rdt.rdtAddMsg 193784, 10, '193784 GET PDKEY FAIL',  'us_english', 840
execute rdt.rdtAddMsg 193785, 10, '193785 INS PDTL FAIL ',  'us_english', 840
execute rdt.rdtAddMsg 193786, 10, '193786 UPD CASE FAIL ',  'us_english', 840

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 193751 AND 193800


