--rdtfnc_Pallet_Putaway
--execute rdt.rdtdropmsg 50021, 50100
execute rdt.rdtAddMsg 50021, 10, '50021^PLT ID req',     'us_english'
execute rdt.rdtAddMsg 50022, 10, '50022^Invalid ID',     'us_english'
execute rdt.rdtAddMsg 50023, 10, '50023^Invalid LOC',    'us_english'
execute rdt.rdtAddMsg 50024, 10, '50024^Wrong Facility', 'us_english'
execute rdt.rdtAddMsg 50025, 10, '50025^No REC found',   'us_english'
execute rdt.rdtAddMsg 50026, 10, '50026^No Avail Loc',   'us_english' -- (Vicky03)
execute rdt.rdtAddMsg 50027, 10, '50027^No Suggest Loc', 'us_english'
execute rdt.rdtAddMsg 50028, 10, '50028^Bad Location',   'us_english'
execute rdt.rdtAddMsg 50029, 10, '50029^TO LOC req',     'us_english'
execute rdt.rdtAddMsg 50030, 10, '50030^Invalid LOC',    'us_english'
execute rdt.rdtAddMsg 50031, 10, '50031^Wrong Facility', 'us_english'

execute rdt.rdtAddMsg 50032, 10, '50032^TASK GEN FAIL', 'us_english'
execute rdt.rdtAddMsg 50033, 10, '50033^INVALID STORER', 'us_english'
execute rdt.rdtAddMsg 50034, 10, '50034^No PnD Loc', 'us_english'
execute rdt.rdtAddMsg 50035, 10, '50035^Bad Location', 'us_english'
execute rdt.rdtAddMsg 50036, 10, '50036^DEL TASK FAIL', 'us_english'

execute rdt.rdtAddMsg 50037, 10, '50037^INVALID STORER', 'us_english'
execute rdt.rdtAddMsg 50038, 10, '50038^Invalid LOC', 'us_english'
execute rdt.rdtAddMsg 50039, 10, '50039^INVALID LOC', 'us_english'
execute rdt.rdtAddMsg 50040, 10, '50040^NO PACKKEY', 'us_english'

execute rdt.rdtAddMsg 50045, 10, '50041^UPD TD FAIL', 'us_english'
execute rdt.rdtAddMsg 50046, 10, '50046^UPD TD FAIL', 'us_english'
--- (Vicky)
execute rdt.rdtAddMsg 50047, 10, '50047^LOC Used', 'us_english'
execute rdt.rdtAddMsg 50048, 10, '50048^IDHasAlloc/PickQty', 'us_english'

-- SOS#175735 
execute rdt.rdtAddMsg 50049, 10, '50049^TASK GEN FAIL', 'us_english'
execute rdt.rdtAddMsg 50050, 10, '50050^TASK GEN FAIL', 'us_english'
execute rdt.rdtAddMsg 50051, 10, '50051^TASK GEN FAIL', 'us_english'
execute rdt.rdtAddMsg 50052, 10, '50052^CASEID Req', 'us_english'
execute rdt.rdtAddMsg 50053, 10, '50053^NoPickLocAssign', 'us_english'
execute rdt.rdtAddMsg 50054, 10, '50054^SKU Req', 'us_english'
execute rdt.rdtAddMsg 50055, 10, '50055^NO PACKKEY', 'us_english'
execute rdt.rdtAddMsg 50056, 10, '50056^UpdCaseIDFail', 'us_english'
execute rdt.rdtAddMsg 50057, 10, '50057^UpdPenMVInFail', 'us_english'
execute rdt.rdtAddMsg 50058, 10, '50058^UpdWCSRouteFail', 'us_english'
execute rdt.rdtAddMsg 50059, 10, '50059^UpdWCSRouteFail', 'us_english'
execute rdt.rdtAddMsg 50060, 10, '50060^TASK GEN FAIL', 'us_english'

execute rdt.rdtAddMsg 50061, 10, '50061^PutawayDoneB4', 'us_english'
execute rdt.rdtAddMsg 50062, 10, '50062^NoInTransitLOC', 'us_english'
execute rdt.rdtAddMsg 50063, 10, '50063^CaseIDInUsed', 'us_english'
execute rdt.rdtAddMsg 50064, 10, '50064^TOLOCNotMatch', 'us_english'
execute rdt.rdtAddMsg 50065, 10, '50065^UpdPAFailed', 'us_english'
execute rdt.rdtAddMsg 50066, 10, '50066^UpdPAFailed', 'us_english'
execute rdt.rdtAddMsg 50067, 10, '50067^UpdPAFailed', 'us_english'
execute rdt.rdtAddMsg 50068, 10, '50068^UpdPAFailed', 'us_english'
execute rdt.rdtAddMsg 50069, 10, '50069^UpdPAFailed', 'us_english'
execute rdt.rdtAddMsg 50070, 10, '50070^UpdTaskFailed', 'us_english'
execute rdt.rdtAddMsg 50071, 10, '50071^CaseIDInUsed', 'us_english'

--(ChewKP06)
execute rdt.rdtAddMsg 50072, 10, '50072^LotNotFound', 'us_english'

-- (Vicky08)
execute rdt.rdtAddMsg 50073, 10, '50073^PLTHasMultiSKU', 'us_english'
execute rdt.rdtAddMsg 50074, 10, '50074^SEE SUPV',       'us_english'
execute rdt.rdtAddMsg 50075, 10, '50075^UpdPAFailed',    'us_english'
execute rdt.rdtAddMsg 50076, 10, '50076^UPD LLI FAIL',   'us_english'
execute rdt.rdtAddMsg 50077, 10, '50077^DEL RFPA FAIL',  'us_english'
execute rdt.rdtAddMsg 50078, 10, '50078^DEL RFPA FAIL',  'us_english'
execute rdt.rdtAddMsg 50079, 10, '50079^UPD LLI FAIL',   'us_english'
execute rdt.rdtAddMsg 50080, 10, '50080^UPD LLI FAIL',   'us_english'
execute rdt.rdtAddMsg 50081, 10, '50081^UPD LLI FAIL',   'us_english'
execute rdt.rdtAddMsg 50082, 10, '50082^DEL RFPA FAIL',  'us_english'
execute rdt.rdtAddMsg 50083, 10, '50083^UPD LLI FAIL',   'us_english'
execute rdt.rdtAddMsg 50084, 10, '50084^DEL RFPA FAIL',  'us_english'

--SOS214021
execute rdt.rdtAddMsg 50085, 10, '50085^INV CASEID LEN', 'us_english'
execute rdt.rdtAddMsg 50086, 10, '50086^SCAN CASE ID',   'us_english'

execute rdt.rdtAddMsg 50091, 10, '50091^FromLoc Req',    'us_english'
execute rdt.rdtAddMsg 50092, 10, '50092^ID in >1 Loc',   'us_english'

--SOS348695
execute rdt.rdtAddMsg 50093, 10, '50093^Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 50094, 10, '50094^SameBarcodeSKU', 'us_english'
execute rdt.rdtAddMsg 50095, 10, '50095^No Record',      'us_english'






