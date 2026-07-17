-- rdt_838ConfirmSP24
-- UWP-48571
execute rdt.rdtdropmsg 274951, 275000

execute rdt.rdtAddMsg 274951, 10, '274951InsPHdrFail   ', 'us_english', 838
execute rdt.rdtAddMsg 274952, 10, '274952GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 274953, 10, '274953GenLabelNoFail', 'us_english', 838
execute rdt.rdtAddMsg 274954, 10, '274954InsPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 274955, 10, '274955UpdPackDtlFail', 'us_english', 838
execute rdt.rdtAddMsg 274956, 10, '274956INSPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 274957, 10, '274957UPDPackInfFail', 'us_english', 838
execute rdt.rdtAddMsg 274958, 10, '274958UPD UCC Fail  ', 'us_english', 838
execute rdt.rdtAddMsg 274959, 10, '274959SN QTYNotTally', 'us_english', 838
execute rdt.rdtAddMsg 274960, 10, '274960INSPackSNOFail', 'us_english', 838
execute rdt.rdtAddMsg 274961, 10, '274961SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 274962, 10, '274962DEL TmpSN Fail', 'us_english', 838
execute rdt.rdtAddMsg 274963, 10, '274963Offset error  ', 'us_english', 838
execute rdt.rdtAddMsg 274964, 10, '274964Offset error  ', 'us_english', 838
execute rdt.rdtAddMsg 274965, 10, '274965INS RDSNo Fail', 'us_english', 838
execute rdt.rdtAddMsg 274966, 10, '274966SNO ady scan  ', 'us_english', 838
execute rdt.rdtAddMsg 274967, 10, '274967INS PDInfoFail', 'us_english', 838
execute rdt.rdtAddMsg 274968, 10, '274968UPD PDInfoFail', 'us_english', 838
execute rdt.rdtAddMsg 274969, 10, '274969UPD PKDtl Fail', 'us_english', 838
execute rdt.rdtAddMsg 274970, 10, '274970UPD PKDtl Fail', 'us_english', 838
execute rdt.rdtAddMsg 274971, 10, '274971nspg_GetKey   ', 'us_english', 838
execute rdt.rdtAddMsg 274972, 10, '274972INS PKDtl Fail', 'us_english', 838
execute rdt.rdtAddMsg 274973, 10, '274973INS RefKeyFail', 'us_english', 838
execute rdt.rdtAddMsg 274974, 10, '274974UPD PKDtl Fail', 'us_english', 838
execute rdt.rdtAddMsg 274975, 10, '274975UPD PKDtl Fail', 'us_english', 838
execute rdt.rdtAddMsg 274976, 10, '274976Offset error  ', 'us_english', 838
execute rdt.rdtAddMsg 274977, 10, '274977PDKey Already Taken', 'us_english', 838

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 274951 AND 275000
