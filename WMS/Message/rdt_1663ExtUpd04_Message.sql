-- rdt_1663ExtUpd04
exec rdt.rdtdropmsg 143051, 143100

execute rdt.rdtAddMsg 143051, 10, '43051^Gen TLOG2 Fail', 'us_english', 1663
execute rdt.rdtAddMsg 143052, 10, '43052^Upd TLOG2 Fail', 'us_english', 1663
execute rdt.rdtAddMsg 143053, 10, '43053^Gen TLOG2 Fail', 'us_english', 1663

--WMS-14482 
execute rdt.rdtAddMsg 143054, 10, '43054^Gen TLOG2 Fail', 'us_english', 1663
execute rdt.rdtAddMsg 143055, 10, '43055^Gen TLOG2 Fail', 'us_english', 1663

-- WMS-17874
execute rdt.rdtAddMsg 143056, 10, '43056^Upd PackInf Er', 'us_english', 1663

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 143051 AND 143100
