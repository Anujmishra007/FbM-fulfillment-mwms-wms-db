-- isp_805PTL_Confirm08
execute rdt.rdtdropmsg 156951 , 157000	

execute rdt.rdtAddMsg 156951, 10, '56951^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 156952, 10, '56952^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 156953, 10, '56953^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 156954, 10, '56954^INS PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 156955, 10, '56955^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 156956, 10, '56956^InsPHdrFail',      'us_english', 805
execute rdt.rdtAddMsg 156957, 10, '56957^InsPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 156958, 10, '56958^UpdPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 156959, 10, '56959^PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 156960, 10, '56960^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156961, 10, '56961^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156962, 10, '56962^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156963, 10, '56963^nspg_GetKey',      'us_english', 805
execute rdt.rdtAddMsg 156964, 10, '56964^INS PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156965, 10, '56965^INS RefKeyFail',   'us_english', 805
execute rdt.rdtAddMsg 156966, 10, '56966^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156967, 10, '56967^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156968, 10, '56968^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156969, 10, '56969^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156970, 10, '56970^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156971, 10, '56971^nspg_GetKey',      'us_english', 805
execute rdt.rdtAddMsg 156972, 10, '56972^INS PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156973, 10, '56973^INS RefKeyFail',   'us_english', 805
execute rdt.rdtAddMsg 156974, 10, '56974^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156975, 10, '56975^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 156976, 10, '56976^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 156977, 10, '56977^PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 156978, 10, '56978^UPD PKDtl Fail',   'us_english', 805


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 156951 AND 157000	
