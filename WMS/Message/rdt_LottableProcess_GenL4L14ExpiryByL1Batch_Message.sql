-- rdt_LottableProcess_GenL4L14ExpiryByL1Batch
execute rdt.rdtDropMsg 58301, 58350

execute rdt.rdtAddMsg 58301, 10, '58301^Invalid Batch ', 'us_english', 608
execute rdt.rdtAddMsg 58302, 10, '58302^Invalid Batch ', 'us_english', 608
execute rdt.rdtAddMsg 58303, 10, '58303^Invalid date  ', 'us_english', 608

-- WMS 11326
execute rdt.rdtAddMsg 58304, 10, '58304^Invalid Hermes ', 'us_english', 608
execute rdt.rdtAddMsg 58305, 10, '58305^Invalid Hermes  ', 'us_english', 608
