
-- Insert Option
INSERT INTO  rdt.RDTmsg 
(Message_ID , Lang_Code, Message_type, Message_Text, StoredProcName)
Values ('1710', 'ENG' , 'FNC', 'Flow Thru Sortation', 'rdtfnc_FlowThruSortation')


-- Message range  63951 - 64000 (rdtfnc_FlowThruSortation)
Execute rdt.rdtDROPMsg 63951 , 64000

execute rdt.rdtAddMsg 63951, 10, '63951^WAVEKEY needed', 'us_english'

execute rdt.rdtAddMsg 63952, 10, '63952^Bad WAVEKEY', 'us_english'

execute rdt.rdtAddMsg 63953, 10, '63953^WaveFullyDistr', 'us_english'


execute rdt.rdtAddMsg 63955, 10, '63955^Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 63956, 10, '63956^QTY needed', 'us_english'

execute rdt.rdtAddMsg 63957, 10, '63957^SKU required', 'us_english'


execute rdt.rdtAddMsg 63958, 10, '63958^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 63959, 10, '63959^MultiSKUBarcod', 'us_english'
execute rdt.rdtAddMsg 63960, 10, '63960^SKU NotOnWave', 'us_english'

execute rdt.rdtAddMsg 63961, 10, '63961^Add WSortFail', 'us_english'
execute rdt.rdtAddMsg 63962, 10, '63962^UPD WSortFail', 'us_english'
execute rdt.rdtAddMsg 63963, 10, '63963^UPD StatusFail', 'us_english'

execute rdt.rdtAddMsg 63965, 10, '63965^Option needed', 'us_english'
execute rdt.rdtAddMsg 63966, 10, '63966^Invalid Option', 'us_english'

execute rdt.rdtAddMsg 63967, 10, '63967^Over scanned', 'us_english'
execute rdt.rdtAddMsg 63968, 10, '63968^Over scanned', 'us_english'
execute rdt.rdtAddMsg 63969, 10, '63969^UPD ODtl Fail', 'us_english'
execute rdt.rdtAddMsg 63970, 10, '63970^Add WDistrFail', 'us_english'
execute rdt.rdtAddMsg 63971, 10, '63971^UPD WDistrFail', 'us_english'
execute rdt.rdtAddMsg 63972, 10, '63972^UPD WSortFail', 'us_english'
execute rdt.rdtAddMsg 63973, 10, '63973^DEL WSortFail', 'us_english'
execute rdt.rdtAddMsg 63974, 10, '63974^UPD WSortFail', 'us_english'

execute rdt.rdtAddMsg 63975, 10, '63975^Option needed', 'us_english'
execute rdt.rdtAddMsg 63976, 10, '63976^Invalid Option', 'us_english'

execute rdt.rdtAddMsg 63977, 10, '63977^UPD WSortFail', 'us_english'
execute rdt.rdtAddMsg 63978, 10, '63978^UPD WDistrFail', 'us_english'


execute rdt.rdtAddMsg 63979, 10, '63979^DEL WSortFail', 'us_english'
execute rdt.rdtAddMsg 63980, 10, '63980^DEL WDistrFail', 'us_english'

execute rdt.rdtAddMsg 63981, 10, '63981^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg 63982, 10, '63982^TgetDB Not Set', 'us_english'
execute rdt.rdtAddMsg 63983, 10, '63983^InsertPRTFail', 'us_english'

--SOS131513
execute rdt.rdtAddMsg 63984, 10, '63984^DWNOTSetup',     'us_english'
execute rdt.rdtAddMsg 63985, 10, '63985^TgetDB Not Set', 'us_english'
execute rdt.rdtAddMsg 63986, 10, '63986^InsertPRTFail',  'us_english'

--SOS279025
execute rdt.rdtAddMsg 63987, 10, '63987^WAVE/LOAD req',  'us_english'
execute rdt.rdtAddMsg 63988, 10, '63988^Bad LOADKEY',    'us_english'
execute rdt.rdtAddMsg 63989, 10, '63989^LoadFullyDistr', 'us_english'
execute rdt.rdtAddMsg 63990, 10, '63990^SKU NotOnLoad',  'us_english'
execute rdt.rdtAddMsg 63991, 10, '63991^Over Scanned',   'us_english'

