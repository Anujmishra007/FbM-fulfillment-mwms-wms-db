-- (rdtfnc_Pick_CaptureDropID)
execute rdt.rdtDropMsg 116351 , 116400

execute rdt.rdtAddMsg 116351, 10, '16351^PSNO required ', 'us_english', 955
execute rdt.rdtAddMsg 116352, 10, '16352^Invalid PSNO  ', 'us_english', 955
execute rdt.rdtAddMsg 116353, 10, '16353^OrderShipped  ', 'us_english', 955
execute rdt.rdtAddMsg 116354, 10, '16354^Diff storer   ', 'us_english', 955
execute rdt.rdtAddMsg 116355, 10, '16355^OrderShipped  ', 'us_english', 955
execute rdt.rdtAddMsg 116356, 10, '16356^Diff storer   ', 'us_english', 955
execute rdt.rdtAddMsg 116357, 10, '16357^OrderShipped  ', 'us_english', 955
execute rdt.rdtAddMsg 116358, 10, '16358^Diff storer   ', 'us_english', 955
execute rdt.rdtAddMsg 116359, 10, '16359^PS not scan in', 'us_english', 955
execute rdt.rdtAddMsg 116360, 10, '16360^PS scanned out', 'us_english', 955
execute rdt.rdtAddMsg 116361, 10, '16361^LOC needed',     'us_english', 955
execute rdt.rdtAddMsg 116362, 10, '16362^Invalid LOC',    'us_english', 955
execute rdt.rdtAddMsg 116363, 10, '16363^Diff facility',  'us_english', 955
execute rdt.rdtAddMsg 116364, 10, '16364^LOC NOT MATCH',  'us_english', 955
execute rdt.rdtAddMsg 116365, 10, '16365^No task in LOC', 'us_english', 955
execute rdt.rdtAddMsg 116366, 10, '16366^Invalid SKU',    'us_english', 955
execute rdt.rdtAddMsg 116367, 10, '16367^MultiSKUBarcod', 'us_english', 955
execute rdt.rdtAddMsg 116368, 10, '16368^Wrong SKU',      'us_english', 955
execute rdt.rdtAddMsg 116369, 10, '16369^Different L01',  'us_english', 955
execute rdt.rdtAddMsg 116370, 10, '16370^Different L02',  'us_english', 955
execute rdt.rdtAddMsg 116371, 10, '16371^Different L03',  'us_english', 955
execute rdt.rdtAddMsg 116372, 10, '16372^Different L04',  'us_english', 955
execute rdt.rdtAddMsg 116373, 10, '16373^Invalid QTY',    'us_english', 955
execute rdt.rdtAddMsg 116374, 10, '16374^Invalid QTY',    'us_english', 955
execute rdt.rdtAddMsg 116375, 10, '16375^Over pick',      'us_english', 955
execute rdt.rdtAddMsg 116376, 10, '16376^DROPID needed',  'us_english', 955
execute rdt.rdtAddMsg 116377, 10, '16377^Invalid Format', 'us_english', 955
execute rdt.rdtAddMsg 116378, 10, '16378^Not Last Ctn',   'us_english', 955
execute rdt.rdtAddMsg 116379, 10, '16379^Pls Scan Ctn',   'us_english', 955
execute rdt.rdtAddMsg 116380, 10, '16380^Option needed',  'us_english', 955
execute rdt.rdtAddMsg 116381, 10, '16381^Invalid Option', 'us_english', 955
execute rdt.rdtAddMsg 116382, 10, '16382^Option needed',  'us_english', 955
execute rdt.rdtAddMsg 116383, 10, '16383^Invalid Option', 'us_english', 955
execute rdt.rdtAddMsg 116384, 10, '16384^Option needed',  'us_english', 955
execute rdt.rdtAddMsg 116385, 10, '16385^Invalid Option', 'us_english', 955

--wms17185
execute rdt.rdtAddMsg 116386, 10, '16386^ScanInFail', 'us_english', 955
execute rdt.rdtAddMsg 116387, 10, '16387^UpdPickInfoFail', 'us_english', 955

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 116351 AND 116400