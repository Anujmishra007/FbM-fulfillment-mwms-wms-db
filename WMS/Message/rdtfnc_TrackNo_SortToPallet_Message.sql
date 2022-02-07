--rdtfnc_TrackNo_SortToPallet
exec rdt.rdtDropMsg 156351 , 156400

execute rdt.rdtAddMsg 156351, 10, '56351^Invalid Option',   'us_english', 1653
execute rdt.rdtAddMsg 156352, 10, '56352^Need Track No',    'us_english', 1653
execute rdt.rdtAddMsg 156353, 10, '56353^No Orders',        'us_english', 1653
execute rdt.rdtAddMsg 156354, 10, '56354^Need Pallet ID',   'us_english', 1653
execute rdt.rdtAddMsg 156355, 10, '56355^INS PalletFail',   'us_english', 1653
execute rdt.rdtAddMsg 156356, 10, '56356^INS PLDtl Fail',   'us_english', 1653
execute rdt.rdtAddMsg 156357, 10, '56357^INS MBOL Fail',    'us_english', 1653
execute rdt.rdtAddMsg 156358, 10, '56358^MBOL Shipped',     'us_english', 1653
execute rdt.rdtAddMsg 156359, 10, '56359^INS MBDtl Fail',   'us_english', 1653
execute rdt.rdtAddMsg 156360, 10, '56360^Need Pallet ID',   'us_english', 1653
execute rdt.rdtAddMsg 156361, 10, '56361^Pallet Not Match', 'us_english', 1653
execute rdt.rdtAddMsg 156362, 10, '56362^INS PLDtl Fail',   'us_english', 1653
execute rdt.rdtAddMsg 156363, 10, '56363^MBOL Shipped',     'us_english', 1653
execute rdt.rdtAddMsg 156364, 10, '56364^INS MBDtl Fail',   'us_english', 1653
execute rdt.rdtAddMsg 156365, 10, '56365^Need Pallet ID',   'us_english', 1653
execute rdt.rdtAddMsg 156366, 10, '56366^Inv Pallet ID',    'us_english', 1653
execute rdt.rdtAddMsg 156367, 10, '56367^Invalid Format',   'us_english', 1653
execute rdt.rdtAddMsg 156368, 10, '56368^GetKey Fail',      'us_english', 1653
execute rdt.rdtAddMsg 156369, 10, '56369^Close PltD Err',   'us_english', 1653
execute rdt.rdtAddMsg 156370, 10, '56370^Close Plt Err',    'us_english', 1653
execute rdt.rdtAddMsg 156371, 10, '56371^Del PltDtl Err',   'us_english', 1653
execute rdt.rdtAddMsg 156372, 10, '56372^Del PltHdr Err',   'us_english', 1653

--WMS-18315
execute rdt.rdtAddMsg 156373, 10, '56373^PltDiffShipper',   'us_english', 1653
execute rdt.rdtAddMsg 156374, 10, '56374^Invalid Format',   'us_english', 1653
execute rdt.rdtAddMsg 156375, 10, '56375^Invalid Format',   'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 156351 AND 156400

