--rdt_941ReplenMove01
EXEC rdt.rdtDropMsg 154751 , 154800	

execute rdt.rdtAddMsg 154751, 10, '154751^Need StorerKey', 'us_english', 941
execute rdt.rdtAddMsg 154752, 10, '154752^Need Facility',  'us_english', 941
execute rdt.rdtAddMsg 154753, 10, '154753^Bad SourceType', 'us_english', 941
execute rdt.rdtAddMsg 154754, 10, '154754^FromLOC needed', 'us_english', 941
execute rdt.rdtAddMsg 154755, 10, '154755^Bad FromLOC',    'us_english', 941
execute rdt.rdtAddMsg 154756, 10, '154756^Diff facility',  'us_english', 941
execute rdt.rdtAddMsg 154757, 10, '154757^ToLOC needed',   'us_english', 941
execute rdt.rdtAddMsg 154758, 10, '154758^Bad ToLOC',      'us_english', 941
execute rdt.rdtAddMsg 154759, 10, '154759^Diff facility',  'us_english', 941
execute rdt.rdtAddMsg 154760, 10, '154760^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 154761, 10, '154761^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 154762, 10, '154762^LocNotCommgSKU', 'us_english', 941
execute rdt.rdtAddMsg 154763, 10, '154763^Invalid ID',     'us_english', 941
execute rdt.rdtAddMsg 154764, 10, '154764^Either SKU/UCC', 'us_english', 941
execute rdt.rdtAddMsg 154765, 10, '154765^Invalid SKU',    'us_english', 941
execute rdt.rdtAddMsg 154766, 10, '154766^LOCHasMultiID',  'us_english', 941
execute rdt.rdtAddMsg 154767, 10, '154767^Invalid QTY',    'us_english', 941
execute rdt.rdtAddMsg 154768, 10, '154768^UCCTrackingOff', 'us_english', 941
execute rdt.rdtAddMsg 154769, 10, '154769^UCCID Unmatch',  'us_english', 941
execute rdt.rdtAddMsg 154770, 10, '154770^UCCLOT Unmatch', 'us_english', 941
execute rdt.rdtAddMsg 154771, 10, '154771^Bad QTY Param',  'us_english', 941
execute rdt.rdtAddMsg 154772, 10, '154772^Invalid LOT',    'us_english', 941
execute rdt.rdtAddMsg 154773, 10, '154773^ItrnMovefailed', 'us_english', 941
execute rdt.rdtAddMsg 154774, 10, '154774^UPD UCC Failed', 'us_english', 941
execute rdt.rdtAddMsg 154775, 10, '154775^UPD RPL Fail',   'us_english', 941
execute rdt.rdtAddMsg 154776, 10, '154776^UPD RPL Fail',   'us_english', 941
execute rdt.rdtAddMsg 154777, 10, '154777^GetPDKeyFail',   'us_english', 941
execute rdt.rdtAddMsg 154778, 10, '154778^CreatePKDFail',  'us_english', 941
execute rdt.rdtAddMsg 154779, 10, '154779^UPD PKD Fail',   'us_english', 941
execute rdt.rdtAddMsg 154780, 10, '154780^InventNotEnuf',  'us_english', 941
execute rdt.rdtAddMsg 154781, 10, '154781^NoOrDtlOffset',  'us_english', 941 
execute rdt.rdtAddMsg 154782, 10, '154782^DWNOTSetup',     'us_english', 941 
execute rdt.rdtAddMsg 154783, 10, '154783^TgetDB Not Set', 'us_english', 941 
execute rdt.rdtAddMsg 154784, 10, '154784^InsertPRTFail',  'us_english', 941
execute rdt.rdtAddMsg 154785, 10, '154785^InsertPRTFail',  'us_english', 941 
execute rdt.rdtAddMsg 154786, 10, '154786^DWNOTSetup',     'us_english', 941 
execute rdt.rdtAddMsg 154787, 10, '154787^TgetDB Not Set', 'us_english', 941 
execute rdt.rdtAddMsg 154788, 10, '154788^UPD UCC Failed', 'us_english', 941

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_Id BETWEEN 154751 AND 154800	