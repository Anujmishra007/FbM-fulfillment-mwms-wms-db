--rdt_1663ExtVal13
exec rdt.rdtdropmsg 159301 , 159350	
execute rdt.rdtAddMsg 159301, 10, '159301OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 159302, 10, '159302OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 159303, 10, '159303^SO_PCANC',   'us_english', 1663
execute rdt.rdtAddMsg 159304, 10, '159304^Repack',   'us_english', 1663
execute rdt.rdtAddMsg 159305, 10, '159305^For_Canc',   'us_english', 1663
execute rdt.rdtAddMsg 159306, 10, '159306NotAllScanned ', 'us_english', 1663




SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 159301 AND 159350
