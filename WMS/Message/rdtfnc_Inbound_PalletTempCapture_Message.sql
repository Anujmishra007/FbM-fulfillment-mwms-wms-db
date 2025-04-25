--rdtfnc_Inbound_PalletTempCapture
--FCR-1398
EXECUTE rdt.rdtdropmsg 230201 , 230250

EXECUTE rdt.rdtAddMsg 230201, 10, '230201ASNIsNeeded',            'us_english', 1869
EXECUTE rdt.rdtAddMsg 230202, 10, '230202ASNNotExist',            'us_english', 1869
EXECUTE rdt.rdtAddMsg 230203, 10, '230203DiffFacility',           'us_english', 1869
EXECUTE rdt.rdtAddMsg 230204, 10, '230204DiffStorer',             'us_english', 1869
EXECUTE rdt.rdtAddMsg 230205, 10, '230205NotInStorerGrp',         'us_english', 1869
EXECUTE rdt.rdtAddMsg 230206, 10, '230206ASNClosed',              'us_english', 1869, 0, '230206 ASN Closed or Cancelled'  --UWP-32818
EXECUTE rdt.rdtAddMsg 230207, 10, '230207ASNCancelled',           'us_english', 1869
EXECUTE rdt.rdtAddMsg 230208, 10, '230208IDIsNeeded',             'us_english', 1869
EXECUTE rdt.rdtAddMsg 230209, 10, '230209InvalidID',              'us_english', 1869, 0, '230209ID does not exist in ASN'
EXECUTE rdt.rdtAddMsg 230210, 10, '230210MultiSKU',               'us_english', 1869, 0, '230210Multiple SKU in the ID'
EXECUTE rdt.rdtAddMsg 230211, 10, '230211TempIsNeeded',           'us_english', 1869
EXECUTE rdt.rdtAddMsg 230212, 10, '230212TempNotNumeric',         'us_english', 1869, 0, '230212Temp is not numeric'
EXECUTE rdt.rdtAddMsg 230213, 10, '230213NoItemClass',            'us_english', 1869
EXECUTE rdt.rdtAddMsg 230214, 10, '230214MissCodeList',           'us_english', 1869
EXECUTE rdt.rdtAddMsg 230215, 10, '230215WrongCodeList',          'us_english', 1869, 0, '230215Item class code needs to be maintained properly'
EXECUTE rdt.rdtAddMsg 230216, 10, '230216CaptureFail',            'us_english', 1869, 0, '230216Capture temperature fail'
EXECUTE rdt.rdtAddMsg 230217, 10, '230217OptionIsNeeded',         'us_english', 1869
EXECUTE rdt.rdtAddMsg 230218, 10, '230218InvalidOption',          'us_english', 1869
EXECUTE rdt.rdtAddMsg 230219, 10, '230219CaptureFail',            'us_english', 1869, 0, '230216Capture temperature fail'

SELECT * FROM rdt.RdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 230201 AND 230250