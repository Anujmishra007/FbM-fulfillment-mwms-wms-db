--rdt_1841PrePltSort04
exec rdt.rdtDropMsg 177701, 177750

execute rdt.rdtAddMsg 177701, 10, '177701^UCC Scanned  ',   'us_english', 1841
execute rdt.rdtAddMsg 177702, 10, '177702^Ins LOG Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 177703, 10, '177703^Upd LOG Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 177704, 10, '177704^Plt NoMixSKU ',   'us_english', 1841
execute rdt.rdtAddMsg 177705, 10, '177705^MaxPltMixSKU ',   'us_english', 1841
execute rdt.rdtAddMsg 177706, 10, '177706^Upd Log Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 177707, 10, '177707^Upd Log Fail ',   'us_english', 1841
execute rdt.rdtAddMsg 177708, 10, '177708^MaxPltCnt Err',   'us_english', 1841
execute rdt.rdtAddMsg 177709, 10, '177709^Pallet Closed',   'us_english', 1841
execute rdt.rdtAddMsg 177710, 10, '177710^DEL UCC Err  ',   'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 177701 AND 177750


