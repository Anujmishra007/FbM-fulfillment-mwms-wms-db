--rdt_1812CfmExtUpd03
execute rdt.rdtdropmsg 203201, 203250

execute rdt.rdtAddMsg 203201, 10, '203201InsPHdrFail   ', 'us_english', 1812
execute rdt.rdtAddMsg 203202, 10, '203202InsPackDtlFail', 'us_english', 1812
execute rdt.rdtAddMsg 203203, 10, '203203UpdPackDtlFail', 'us_english', 1812
execute rdt.rdtAddMsg 203204, 10, '203204UPDPackInfFail', 'us_english', 1812
execute rdt.rdtAddMsg 203205, 10, '203205INSPackInfFail', 'us_english', 1812
execute rdt.rdtAddMsg 203205, 10, '203205INSPKHdrFail  ', 'us_english', 1812
