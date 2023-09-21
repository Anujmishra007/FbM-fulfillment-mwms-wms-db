--rdt_941ReplenMove02
EXEC rdt.rdtDropMsg 206401 , 206450	

execute rdt.rdtAddMsg 206401, 10, '206401^Need StorerKey', 'us_english', 941
execute rdt.rdtAddMsg 206402, 10, '206402^Need Facility',  'us_english', 941
execute rdt.rdtAddMsg 206403, 10, '206403^Bad SourceType', 'us_english', 941
execute rdt.rdtAddMsg 206404, 10, '206404^FromLOC needed', 'us_english', 941
execute rdt.rdtAddMsg 206405, 10, '206405^Bad FromLOC',    'us_english', 941
execute rdt.rdtAddMsg 206406, 10, '206406^Diff facility',  'us_english', 941
execute rdt.rdtAddMsg 206407, 10, '206407^ToLOC needed',   'us_english', 941
execute rdt.rdtAddMsg 206408, 10, '206408^Bad ToLOC',      'us_english', 941
execute rdt.rdtAddMsg 206409, 10, '206409^Diff facility',  'us_english', 941
execute rdt.rdtAddMsg 206410, 10, '206410^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 206411, 10, '206411^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 206412, 10, '206412^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 206413, 10, '206413^Invalid ID',     'us_english', 941
execute rdt.rdtAddMsg 206414, 10, '206414^Either SKU/UCC', 'us_english', 941
execute rdt.rdtAddMsg 206415, 10, '206415^Invalid SKU',    'us_english', 941
execute rdt.rdtAddMsg 206416, 10, '206416^LOCHasMultiID',  'us_english', 941
execute rdt.rdtAddMsg 206417, 10, '206417^Invalid QTY',    'us_english', 941
execute rdt.rdtAddMsg 206418, 10, '206418^UCCTrackingOff', 'us_english', 941
execute rdt.rdtAddMsg 206419, 10, '206419^UCCID Unmatch',  'us_english', 941
execute rdt.rdtAddMsg 206420, 10, '206420^UCCLOT Unmatch', 'us_english', 941
execute rdt.rdtAddMsg 206421, 10, '206421^Bad QTY Param',  'us_english', 941
execute rdt.rdtAddMsg 206422, 10, '206422^Invalid LOT',    'us_english', 941
execute rdt.rdtAddMsg 206423, 10, '206423^ItrnMovefailed', 'us_english', 941
execute rdt.rdtAddMsg 206424, 10, '206424^UPD UCC Failed', 'us_english', 941
execute rdt.rdtAddMsg 206425, 10, '206425^UPD RPL Fail',   'us_english', 941
execute rdt.rdtAddMsg 206426, 10, '206426^UPD RPL Fail',   'us_english', 941
execute rdt.rdtAddMsg 206427, 10, '206427^GetPDKeyFail',   'us_english', 941
execute rdt.rdtAddMsg 206428, 10, '206428^CreatePKDFail',  'us_english', 941
execute rdt.rdtAddMsg 206429, 10, '206429^UPD PKD Fail',   'us_english', 941
execute rdt.rdtAddMsg 206430, 10, '206430^InventNotEnuf',  'us_english', 941
execute rdt.rdtAddMsg 206431, 10, '206431^NoOrDtlOffset',  'us_english', 941 
execute rdt.rdtAddMsg 206432, 10, '206432^UPD PDDtl Err',  'us_english', 941

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_Id BETWEEN 206401 AND 206450	