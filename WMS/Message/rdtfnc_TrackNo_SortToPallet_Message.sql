--rdtfnc_TrackNo_SortToPallet
exec rdt.rdtDropMsg 156351 , 156400
exec rdt.rdtDropMsg 189801 , 189850

execute rdt.rdtAddMsg 156351, 10, '156351^Invalid Option',   'us_english', 1653
execute rdt.rdtAddMsg 156352, 10, '156352^Need Track No',    'us_english', 1653
execute rdt.rdtAddMsg 156353, 10, '156353^No Orders',        'us_english', 1653
execute rdt.rdtAddMsg 156354, 10, '156354^Need Pallet ID',   'us_english', 1653
execute rdt.rdtAddMsg 156355, 10, '156355^INS PalletFail',   'us_english', 1653
execute rdt.rdtAddMsg 156356, 10, '156356^INS PLDtl Fail',   'us_english', 1653
execute rdt.rdtAddMsg 156357, 10, '156357^INS MBOL Fail',    'us_english', 1653
execute rdt.rdtAddMsg 156358, 10, '156358^MBOL Shipped',     'us_english', 1653
execute rdt.rdtAddMsg 156359, 10, '156359^INS MBDtl Fail',   'us_english', 1653
execute rdt.rdtAddMsg 156360, 10, '156360^Need Pallet ID',   'us_english', 1653
execute rdt.rdtAddMsg 156361, 10, '156361^Pallet Not Match', 'us_english', 1653
execute rdt.rdtAddMsg 156362, 10, '156362^INS PLDtl Fail',   'us_english', 1653
execute rdt.rdtAddMsg 156363, 10, '156363^MBOL Shipped',     'us_english', 1653
execute rdt.rdtAddMsg 156364, 10, '156364^INS MBDtl Fail',   'us_english', 1653
execute rdt.rdtAddMsg 156365, 10, '156365^Need Pallet ID',   'us_english', 1653
execute rdt.rdtAddMsg 156366, 10, '156366^Inv Pallet ID',    'us_english', 1653
execute rdt.rdtAddMsg 156367, 10, '156367^Invalid Format',   'us_english', 1653
execute rdt.rdtAddMsg 156368, 10, '156368^GetKey Fail',      'us_english', 1653
execute rdt.rdtAddMsg 156369, 10, '156369^Close PltD Err',   'us_english', 1653
execute rdt.rdtAddMsg 156370, 10, '156370^Close Plt Err',    'us_english', 1653
execute rdt.rdtAddMsg 156371, 10, '156371^Del PltDtl Err',   'us_english', 1653
execute rdt.rdtAddMsg 156372, 10, '156372^Del PltHdr Err',   'us_english', 1653

--WMS-18315
execute rdt.rdtAddMsg 156373, 10, '156373^PltDiffShipper',   'us_english', 1653
execute rdt.rdtAddMsg 156374, 10, '156374^Invalid Format',   'us_english', 1653
execute rdt.rdtAddMsg 156375, 10, '156375^Invalid Format',   'us_english', 1653

--WMS-19218
execute rdt.rdtAddMsg 156376, 10, '156376^Option required',   'us_english', 1653
execute rdt.rdtAddMsg 156377, 10, '156377^Invalid Option',    'us_english', 1653
execute rdt.rdtAddMsg 156378, 10, '156378^PltDiffShipper',    'us_english', 1653
execute rdt.rdtAddMsg 156379, 10, '156379^Del PltDtl Err',    'us_english', 1653
execute rdt.rdtAddMsg 156380, 10, '156380^Del PltHdr Err',    'us_english', 1653
execute rdt.rdtAddMsg 156381, 10, '156381^INS PalletFail',    'us_english', 1653
execute rdt.rdtAddMsg 156382, 10, '156382^INS PLDtl Fail',    'us_english', 1653
execute rdt.rdtAddMsg 156383, 10, '156383^GetKey Fail',       'us_english', 1653
execute rdt.rdtAddMsg 156384, 10, '156384^MBOL Shipped',      'us_english', 1653
execute rdt.rdtAddMsg 156385, 10, '156385^INS MBDtl Fail',    'us_english', 1653
execute rdt.rdtAddMsg 156386, 10, '156386^Need Weight',       'us_english', 1653
execute rdt.rdtAddMsg 156387, 10, '156387^Invalid Format',    'us_english', 1653
execute rdt.rdtAddMsg 156388, 10, '156388^Invalid weight',    'us_english', 1653
execute rdt.rdtAddMsg 156389, 10, '156389^Need Length',       'us_english', 1653
execute rdt.rdtAddMsg 156390, 10, '156390^Invalid Length',    'us_english', 1653
execute rdt.rdtAddMsg 156391, 10, '156391^Need Width',        'us_english', 1653
execute rdt.rdtAddMsg 156392, 10, '156392^Invalid Width',     'us_english', 1653
execute rdt.rdtAddMsg 156393, 10, '156393^Need Height',       'us_english', 1653
execute rdt.rdtAddMsg 156394, 10, '156394^Invalid Height',    'us_english', 1653
execute rdt.rdtAddMsg 156395, 10, '156395^Close PltD Err',    'us_english', 1653
execute rdt.rdtAddMsg 156396, 10, '156396^Close Plt Err',     'us_english', 1653
execute rdt.rdtAddMsg 156397, 10, '156397^Diff StorerKey',    'us_english', 1653
execute rdt.rdtAddMsg 156398, 10, '156398^Diff StorerKey',    'us_english', 1653
execute rdt.rdtAddMsg 156399, 10, '156399^Diff StorerKey',    'us_english', 1653

--WMS-20033
execute rdt.rdtAddMsg 156400, 10, '156400^Pallet In Use',     'us_english', 1653

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

