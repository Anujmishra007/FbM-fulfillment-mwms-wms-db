-- rdtfnc_PTLStation_CloseStation
execute rdt.rdtDropMsg 123351 , 123400

execute rdt.rdtAddMsg 123351, 10, '23351^PTLStation req', 'us_english', 802
execute rdt.rdtAddMsg 123352, 10, '23352^StationScanned', 'us_english', 802

execute rdt.rdtAddMsg 123354, 10, '23354^InvalidStation', 'us_english', 802
execute rdt.rdtAddMsg 123355, 10, '23355^Need method   ', 'us_english', 802
execute rdt.rdtAddMsg 123356, 10, '23356^SetupMethodSP ', 'us_english', 802
execute rdt.rdtAddMsg 123357, 10, '23357^Bad Method SP ', 'us_english', 802
execute rdt.rdtAddMsg 123358, 10, '23358^Need Option   ', 'us_english', 802
execute rdt.rdtAddMsg 123359, 10, '23359^Invalid Option', 'us_english', 802
execute rdt.rdtAddMsg 123360, 10, '23360^PutNotFinish', 'us_english', 802
