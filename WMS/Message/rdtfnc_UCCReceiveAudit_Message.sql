-- rdtfnc_UCCReceiveAudit
rdt.rdtdropmsg 147051, 147100

execute rdt.rdtAddMsg 147051, 10, '47051^Need ASN',         'us_english', 1840
execute rdt.rdtAddMsg 147052, 10, '47052^ASN not exists',   'us_english', 1840
execute rdt.rdtAddMsg 147053, 10, '47053^Diff facility',    'us_english', 1840
execute rdt.rdtAddMsg 147054, 10, '47054^Diff storer',      'us_english', 1840
execute rdt.rdtAddMsg 147055, 10, '47055^UCC required',     'us_english', 1840
execute rdt.rdtAddMsg 147056, 10, '47056^UCC Not Exists',   'us_english', 1840
execute rdt.rdtAddMsg 147057, 10, '47057^UCC notIN ASN',    'us_english', 1840
execute rdt.rdtAddMsg 147058, 10, '47058^Need Option',      'us_english', 1840
execute rdt.rdtAddMsg 147059, 10, '47059^Invalid Option',   'us_english', 1840
execute rdt.rdtAddMsg 147060, 10, '47060^DEL Log Fail',     'us_english', 1840
execute rdt.rdtAddMsg 147061, 10, '47061^SKU required',     'us_english', 1840
execute rdt.rdtAddMsg 147062, 10, '47062^Invalid SKU',      'us_english', 1840
execute rdt.rdtAddMsg 147063, 10, '47063^SKU NotExists',    'us_english', 1840
execute rdt.rdtAddMsg 147066, 10, '47066^OptionRequired',   'us_english', 1840
execute rdt.rdtAddMsg 147067, 10, '47067^Invalid Option',   'us_english', 1840
execute rdt.rdtAddMsg 147068, 10, '47068^NotFinalize',      'us_english', 1840

--WMS-12451
execute rdt.rdtAddMsg 147074, 10, '47074^UCC NotReceive',   'us_english', 1840
execute rdt.rdtAddMsg 147075, 10, '47075^Inv UCC Status',   'us_english', 1840
