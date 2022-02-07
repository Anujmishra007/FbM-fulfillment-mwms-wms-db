--rdt_941ReplenMove01
rdt.rdtAddMsg 154751 , 154800	

execute rdt.rdtAddMsg 54751, 10, '54751^Need StorerKey', 'us_english', 941
execute rdt.rdtAddMsg 54752, 10, '54752^Need Facility',  'us_english', 941
execute rdt.rdtAddMsg 54753, 10, '54753^Bad SourceType', 'us_english', 941
execute rdt.rdtAddMsg 54754, 10, '54754^FromLOC needed', 'us_english', 941
execute rdt.rdtAddMsg 54755, 10, '54755^Bad FromLOC',    'us_english', 941
execute rdt.rdtAddMsg 54756, 10, '54756^Diff facility',  'us_english', 941
execute rdt.rdtAddMsg 54757, 10, '54757^ToLOC needed',   'us_english', 941
execute rdt.rdtAddMsg 54758, 10, '54758^Bad ToLOC',      'us_english', 941
execute rdt.rdtAddMsg 54759, 10, '54759^Diff facility',  'us_english', 941
execute rdt.rdtAddMsg 54760, 10, '54760^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 54761, 10, '54761^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 54762, 10, '54762^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 54763, 10, '54763^Invalid ID',     'us_english', 941
execute rdt.rdtAddMsg 54764, 10, '54764^Either SKU/UCC', 'us_english', 941
execute rdt.rdtAddMsg 54765, 10, '54765^Invalid SKU',    'us_english', 941
execute rdt.rdtAddMsg 54766, 10, '54766^LOCHasMultiID',  'us_english', 941
execute rdt.rdtAddMsg 54767, 10, '54767^Invalid QTY',    'us_english', 941
execute rdt.rdtAddMsg 54768, 10, '54768^UCCTrackingOff', 'us_english', 941
execute rdt.rdtAddMsg 54769, 10, '54769^UCCID Unmatch',  'us_english', 941
execute rdt.rdtAddMsg 54770, 10, '54770^UCCLOT Unmatch', 'us_english', 941
execute rdt.rdtAddMsg 54771, 10, '54771^Bad QTY Param',  'us_english', 941
execute rdt.rdtAddMsg 54772, 10, '54772^Invalid LOT',    'us_english', 941
execute rdt.rdtAddMsg 54773, 10, '54773^ItrnMovefailed', 'us_english', 941
execute rdt.rdtAddMsg 54774, 10, '54774^UPD UCC Failed', 'us_english', 941
execute rdt.rdtAddMsg 54775, 10, '54775^UPD RPL Fail',   'us_english', 941
execute rdt.rdtAddMsg 54776, 10, '54776^UPD RPL Fail',   'us_english', 941
execute rdt.rdtAddMsg 54777, 10, '54777^GetPDKeyFail',   'us_english', 941
execute rdt.rdtAddMsg 54778, 10, '54778^CreatePKDFail',  'us_english', 941
execute rdt.rdtAddMsg 54779, 10, '54779^UPD PKD Fail',   'us_english', 941
execute rdt.rdtAddMsg 54780, 10, '54780^InventNotEnuf',  'us_english', 941
execute rdt.rdtAddMsg 54781, 10, '54781^NoOrDtlOffset',  'us_english', 941 
execute rdt.rdtAddMsg 54782, 10, '54782^DWNOTSetup',     'us_english', 941 
execute rdt.rdtAddMsg 54783, 10, '54783^TgetDB Not Set', 'us_english', 941 
execute rdt.rdtAddMsg 54784, 10, '54784^InsertPRTFail',  'us_english', 941
execute rdt.rdtAddMsg 54785, 10, '54785^InsertPRTFail',  'us_english', 941 
execute rdt.rdtAddMsg 54786, 10, '54786^DWNOTSetup',     'us_english', 941 
execute rdt.rdtAddMsg 54787, 10, '54787^TgetDB Not Set', 'us_english', 941 

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_Id BETWEEN 154751 AND 154800	