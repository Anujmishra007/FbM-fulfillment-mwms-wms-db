--rdt_941ReplenMove03
--FCR-939
EXEC rdt.rdtDropMsg 225401 , 225450	

execute rdt.rdtAddMsg 225401, 10, '206401^Need StorerKey', 'us_english', 941
execute rdt.rdtAddMsg 225402, 10, '206402^Need Facility',  'us_english', 941
execute rdt.rdtAddMsg 225403, 10, '206403^Bad SourceType', 'us_english', 941
execute rdt.rdtAddMsg 225404, 10, '206404^FromLOC needed', 'us_english', 941
execute rdt.rdtAddMsg 225405, 10, '206405^Bad FromLOC',    'us_english', 941
execute rdt.rdtAddMsg 225406, 10, '206406^Diff facility',  'us_english', 941
execute rdt.rdtAddMsg 225407, 10, '206407^ToLOC needed',   'us_english', 941
execute rdt.rdtAddMsg 225408, 10, '206408^Bad ToLOC',      'us_english', 941
execute rdt.rdtAddMsg 225409, 10, '206409^Diff facility',  'us_english', 941
execute rdt.rdtAddMsg 225410, 10, '206410^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 225411, 10, '206411^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 225412, 10, '206412^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 225413, 10, '206413^Invalid ID',     'us_english', 941
execute rdt.rdtAddMsg 225414, 10, '206414^Either SKU/UCC', 'us_english', 941
execute rdt.rdtAddMsg 225415, 10, '206415^Invalid SKU',    'us_english', 941
execute rdt.rdtAddMsg 225416, 10, '206416^LOCHasMultiID',  'us_english', 941
execute rdt.rdtAddMsg 225417, 10, '206417^Invalid QTY',    'us_english', 941
execute rdt.rdtAddMsg 225418, 10, '206418^UCCTrackingOff', 'us_english', 941
execute rdt.rdtAddMsg 225419, 10, '206419^UCCID Unmatch',  'us_english', 941
execute rdt.rdtAddMsg 225420, 10, '206420^UCCLOT Unmatch', 'us_english', 941
execute rdt.rdtAddMsg 225421, 10, '206421^Bad QTY Param',  'us_english', 941
execute rdt.rdtAddMsg 225422, 10, '206422^Invalid LOT',    'us_english', 941
execute rdt.rdtAddMsg 225423, 10, '206423^ItrnMovefailed', 'us_english', 941
execute rdt.rdtAddMsg 225424, 10, '206424^UPD UCC Failed', 'us_english', 941
execute rdt.rdtAddMsg 225425, 10, '206425^UPD RPL Fail',   'us_english', 941
execute rdt.rdtAddMsg 225426, 10, '206426^UPD RPL Fail',   'us_english', 941
execute rdt.rdtAddMsg 225427, 10, '206427^GetPDKeyFail',   'us_english', 941
execute rdt.rdtAddMsg 225428, 10, '206428^CreatePKDFail',  'us_english', 941
execute rdt.rdtAddMsg 225429, 10, '206429^UPD PKD Fail',   'us_english', 941
execute rdt.rdtAddMsg 225430, 10, '206430^InventNotEnuf',  'us_english', 941
execute rdt.rdtAddMsg 225431, 10, '206431^NoOrDtlOffset',  'us_english', 941 
execute rdt.rdtAddMsg 225432, 10, '206432^UPD PDDtl Err',  'us_english', 941
execute rdt.rdtAddMsg 225433, 10, '206433^UnlockLocFail',  'us_english', 941

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_Id BETWEEN 225401 AND 225450	