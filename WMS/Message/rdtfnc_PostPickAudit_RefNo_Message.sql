-- rdtfnc_PostPickAudit_RefNo
execute rdt.rdtDropMsg 104751 , 104800

execute rdt.rdtAddMsg 104751, 10, '04751^Value Required', 'us_english', 905
execute rdt.rdtAddMsg 104752, 10, '04752^Invalid RefNo ', 'us_english', 905
execute rdt.rdtAddMsg 104753, 10, '04753^SKU is require', 'us_english', 905
execute rdt.rdtAddMsg 104754, 10, '04754^Invalid SKU   ', 'us_english', 905
execute rdt.rdtAddMsg 104755, 10, '04755^MultiSKUBarcod', 'us_english', 905
execute rdt.rdtAddMsg 104756, 10, '04756^SKU NOT IN ORD', 'us_english', 905
execute rdt.rdtAddMsg 104757, 10, '04757^Invalid QTY   ', 'us_english', 905
execute rdt.rdtAddMsg 104758, 10, '04758^Invalid QTY   ', 'us_english', 905
execute rdt.rdtAddMsg 104759, 10, '04759^>ALLOCATED QTY', 'us_english', 905
execute rdt.rdtAddMsg 104760, 10, '04760^Fail INS PPA  ', 'us_english', 905
execute rdt.rdtAddMsg 104761, 10, '04761^Fail UPD PPA  ', 'us_english', 905
execute rdt.rdtAddMsg 104762, 10, '04762^ScanIn Fail   ', 'us_english', 905
execute rdt.rdtAddMsg 104763, 10, '04763^ScanIn Fail   ', 'us_english', 905
execute rdt.rdtAddMsg 104764, 10, '04764^GetPKSLIP Fail', 'us_english', 905
execute rdt.rdtAddMsg 104765, 10, '04765^ScanIn Fail   ', 'us_english', 905
execute rdt.rdtAddMsg 104766, 10, '04766^SKU Not ALLOC ', 'us_english', 905

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 104751 AND 104800