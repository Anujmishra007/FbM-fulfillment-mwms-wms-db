--isp_805PTL_Confirm11
rdt.rdtDropMsg 166601 , 166650	

execute rdt.rdtAddMsg 166601, 10, '166601UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 166602, 10, '166602UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 166603, 10, '166603UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 166604, 10, '166604INS PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 166605, 10, '166605UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 166606, 10, '166606PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 166607, 10, '166607UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 166608, 10, '166608UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 166609, 10, '166609UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 166610, 10, '166610nspg_GetKey',      'us_english', 805
execute rdt.rdtAddMsg 166611, 10, '166611INS PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 166612, 10, '166612INS RefKeyFail',   'us_english', 805
execute rdt.rdtAddMsg 166613, 10, '166613UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 166614, 10, '166614UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 166615, 10, '166615InsPHdrFail',      'us_english', 805
execute rdt.rdtAddMsg 166616, 10, '166616InsPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 166617, 10, '166617UpdPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 166618, 10, '166618PackCfm Fail',     'us_english', 805
execute rdt.rdtAddMsg 166619, 10, '166619UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 166620, 10, '166620PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 166621, 10, '166621UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 166622, 10, '166622Get PALOC Err',    'us_english', 805
execute rdt.rdtAddMsg 166623, 10, '166623Get PALOC Err',    'us_english', 805
execute rdt.rdtAddMsg 166624, 10, '166624nspg_getkey',      'us_english', 805
execute rdt.rdtAddMsg 166625, 10, '166625CreateASTRPTEr',   'us_english', 805
execute rdt.rdtAddMsg 166626, 10, '166626UpdWCSRODetErr',   'us_english', 805
execute rdt.rdtAddMsg 166627, 10, '166627UpdWCSROErr',      'us_english', 805
execute rdt.rdtAddMsg 166628, 10, '166628UpdPTLStnLogEr',   'us_english', 805

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 166601 AND 166650