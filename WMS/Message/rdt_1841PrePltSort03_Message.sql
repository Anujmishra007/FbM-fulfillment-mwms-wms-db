--rdt_1841PrePltSort03
exec rdt.rdtDropMsg 170701, 170750

execute rdt.rdtAddMsg 170701, 10, '170701^UCC Scanned  ',   'us_english', 1841
execute rdt.rdtAddMsg 170702, 10, '170702^Ins LOG Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 170703, 10, '170703^Upd LOG Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 170704, 10, '170704^Plt NoMixSKU ',   'us_english', 1841
execute rdt.rdtAddMsg 170705, 10, '170705^MaxPltMixSKU ',   'us_english', 1841
execute rdt.rdtAddMsg 170706, 10, '170706^Upd Log Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 170707, 10, '170707^Upd Log Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 170708, 10, '170708^MaxPltCnt Err',   'us_english', 1841
execute rdt.rdtAddMsg 170709, 10, '170709^Pallet Closed',   'us_english', 1841
execute rdt.rdtAddMsg 170710, 10, '170710^DEL UCC Err  ',   'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 170701 AND 170750


