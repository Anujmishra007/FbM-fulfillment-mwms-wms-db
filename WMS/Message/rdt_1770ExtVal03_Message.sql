--rdt.rdt_1770ExtVal03
execute rdt.rdtdropmsg 226101,226150

execute rdt.rdtAddMsg 226101, 10, '226101Error',   'us_english', 1770,0,'226101Cannot Override Marshalling Location'
execute rdt.rdtAddMsg 226102, 10, '226102Error',   'us_english', 1770,0,'226102Cannot Override Not a VAS Location'
execute rdt.rdtAddMsg 226103, 10, '226103Invalid DropID',   'us_english', 1770
execute rdt.rdtAddMsg 226104, 10, '226104Error',   'us_english', 1770,0,'226104To Loc Must Be Marshalling Location Or VAS Location'
