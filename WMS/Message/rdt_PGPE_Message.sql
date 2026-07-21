-- PGPE Customization Messages
-- UWP-61800
execute rdt.rdtdropmsg 275051, 275100

-- rdt_1819ExtUpdPGPE
execute rdt.rdtAddMsg 275051, 10, '275051^InsTaskDetFail    ', 'us_english', 1819

-- rdt_600ExtUpdPGPE
execute rdt.rdtAddMsg 275058, 10, '275058^UpdStickerFail    ', 'us_english', 600
execute rdt.rdtAddMsg 275059, 10, '275059^UpdPrintedFail    ', 'us_english', 600

-- rdt_600ExtVal_PGPE
execute rdt.rdtAddMsg 275052, 10, '275052^Used LPN          ', 'us_english', 600
execute rdt.rdtAddMsg 275053, 10, '275053^Max 5 batch by pal', 'us_english', 600
execute rdt.rdtAddMsg 275054, 10, '275054^Diff.ExpDate>90day', 'us_english', 600
execute rdt.rdtAddMsg 275055, 10, '275055^Exceed.Qty>MaxPal ', 'us_english', 600

-- rdt_LottableProcess_ExpiredValL04_PGPE
execute rdt.rdtAddMsg 275056, 10, '275056^Lottable04 req    ', 'us_english', 600
execute rdt.rdtAddMsg 275057, 10, '275057^ExpDate<Today     ', 'us_english', 600

-- rdt_652ExtUpdPGPE
execute rdt.rdtAddMsg 275060, 10, '275060^UpdBkInArrFail    ', 'us_english', 652
execute rdt.rdtAddMsg 275061, 10, '275061^UpdBkInDepFail    ', 'us_english', 652
execute rdt.rdtAddMsg 275062, 10, '275062^UpdBkInStrtFail   ', 'us_english', 652
execute rdt.rdtAddMsg 275063, 10, '275063^UpdBkInEndFail    ', 'us_english', 652
execute rdt.rdtAddMsg 275064, 10, '275064^UpdBkOutArrFail   ', 'us_english', 652
execute rdt.rdtAddMsg 275065, 10, '275065^UpdBkOutDepFail   ', 'us_english', 652
execute rdt.rdtAddMsg 275066, 10, '275066^UpdBkOutStrtFail  ', 'us_english', 652
execute rdt.rdtAddMsg 275067, 10, '275067^UpdBkOutEndFail   ', 'us_english', 652

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 275051 AND 275100
