-- rdt_1765ExtUpdSP02
execute rdt.rdtDropMsg 98301,  98350


execute rdt.rdtAddMsg 98301, 10, '98301^UpdTaskDetFail', 'us_english', 1765
execute rdt.rdtAddMsg 98302, 10, '98302^UpdTaskDetFail', 'us_english', 1765

--WMS-17060
execute rdt.rdtAddMsg 98303, 10, '98303^Ins TL2 Fail',   'us_english', 1765
