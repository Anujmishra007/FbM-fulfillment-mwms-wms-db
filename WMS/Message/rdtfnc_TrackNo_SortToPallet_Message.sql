--rdtfnc_TrackNo_SortToPallet
exec rdt.rdtDropMsg 156351 , 156400
exec rdt.rdtDropMsg 189801 , 189850

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

--WMS-19218
execute rdt.rdtAddMsg 156376, 10, '56376^Option required',   'us_english', 1653
execute rdt.rdtAddMsg 156377, 10, '56377^Invalid Option',    'us_english', 1653
execute rdt.rdtAddMsg 156378, 10, '56378^PltDiffShipper',    'us_english', 1653
execute rdt.rdtAddMsg 156379, 10, '56379^Del PltDtl Err',    'us_english', 1653
execute rdt.rdtAddMsg 156380, 10, '56380^Del PltHdr Err',    'us_english', 1653
execute rdt.rdtAddMsg 156381, 10, '56381^INS PalletFail',    'us_english', 1653
execute rdt.rdtAddMsg 156382, 10, '56382^INS PLDtl Fail',    'us_english', 1653
execute rdt.rdtAddMsg 156383, 10, '56383^GetKey Fail',       'us_english', 1653
execute rdt.rdtAddMsg 156384, 10, '56384^MBOL Shipped',      'us_english', 1653
execute rdt.rdtAddMsg 156385, 10, '56385^INS MBDtl Fail',    'us_english', 1653
execute rdt.rdtAddMsg 156386, 10, '56386^Need Weight',       'us_english', 1653
execute rdt.rdtAddMsg 156387, 10, '56387^Invalid Format',    'us_english', 1653
execute rdt.rdtAddMsg 156388, 10, '56388^Invalid weight',    'us_english', 1653
execute rdt.rdtAddMsg 156389, 10, '56389^Need Length',       'us_english', 1653
execute rdt.rdtAddMsg 156390, 10, '56390^Invalid Length',    'us_english', 1653
execute rdt.rdtAddMsg 156391, 10, '56391^Need Width',        'us_english', 1653
execute rdt.rdtAddMsg 156392, 10, '56392^Invalid Width',     'us_english', 1653
execute rdt.rdtAddMsg 156393, 10, '56393^Need Height',       'us_english', 1653
execute rdt.rdtAddMsg 156394, 10, '56394^Invalid Height',    'us_english', 1653
execute rdt.rdtAddMsg 156395, 10, '56395^Close PltD Err',    'us_english', 1653
execute rdt.rdtAddMsg 156396, 10, '56396^Close Plt Err',     'us_english', 1653
execute rdt.rdtAddMsg 156397, 10, '56397^Diff StorerKey',    'us_english', 1653
execute rdt.rdtAddMsg 156398, 10, '56398^Diff StorerKey',    'us_english', 1653
execute rdt.rdtAddMsg 156399, 10, '56399^Diff StorerKey',    'us_english', 1653

--WMS-20033
execute rdt.rdtAddMsg 156400, 10, '56400^Pallet In Use',     'us_english', 1653

execute rdt.rdtAddMsg 189801, 10, '189801 Pallet Closed',    'us_english', 1653

-- WMS-20561
execute rdt.rdtAddMsg 189802, 10, '189802Inv Ord Status',    'us_english', 1653

-- WMS-20667
execute rdt.rdtAddMsg 189803, 10, '189803 OrdersShipped',    'us_english', 1653
execute rdt.rdtAddMsg 189804, 10, '189804OrdInOtherLane',    'us_english', 1653
execute rdt.rdtAddMsg 189805, 10, '189805 Need Lane    ',    'us_english', 1653
execute rdt.rdtAddMsg 189806, 10, '189806 Lane Closed  ',    'us_english', 1653
execute rdt.rdtAddMsg 189807, 10, '189807PltInOtherLane',    'us_english', 1653
execute rdt.rdtAddMsg 189808, 10, '189808OrdInOtherLane',    'us_english', 1653
execute rdt.rdtAddMsg 189809, 10, '189809PltInOtherLane',    'us_english', 1653
execute rdt.rdtAddMsg 189810, 10, '189810Invalid Format',    'us_english', 1653
execute rdt.rdtAddMsg 189811, 10, '189811 Need Lane    ',    'us_english', 1653
execute rdt.rdtAddMsg 189812, 10, '189812 DifferentLane',    'us_english', 1653
execute rdt.rdtAddMsg 189813, 10, '189813Invalid Format',    'us_english', 1653
execute rdt.rdtAddMsg 189814, 10, '189814 Pallet In Use',    'us_english', 1653
execute rdt.rdtAddMsg 189815, 10, '189814Diff StorerKey',    'us_english', 1653
execute rdt.rdtAddMsg 189816, 10, '189816PltInOtherLane',    'us_english', 1653
execute rdt.rdtAddMsg 189817, 10, '189817 TrackNo InUse',    'us_english', 1653
execute rdt.rdtAddMsg 189818, 10, '189818 Lane In Use  ',    'us_english', 1653
execute rdt.rdtAddMsg 189819, 10, '189819 LaneAlrdSplit',    'us_english', 1653
execute rdt.rdtAddMsg 189820, 10, '189820 LaneAlrdSplit',    'us_english', 1653
execute rdt.rdtAddMsg 189821, 10, '189821 LaneAlrdSplit',    'us_english', 1653
execute rdt.rdtAddMsg 189822, 10, '189822 LaneAlrdSplit',    'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 156351 AND 156400

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 189801 AND 189850

