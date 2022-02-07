-- rdt_SortAndPack_Confirm
exec rdt.rdtDropMsg 77401, 77450

execute rdt.rdtAddMsg 77401, 10, '77401 UPD PKDtl Fail', 'us_english', 540
execute rdt.rdtAddMsg 77402, 10, '77402 UPD PKDtl Fail', 'us_english', 540
execute rdt.rdtAddMsg 77403, 10, '77403 GetKey Fail   ', 'us_english', 540
execute rdt.rdtAddMsg 77404, 10, '77404 INS PKDtl Fail', 'us_english', 540
execute rdt.rdtAddMsg 77405, 10, '77405 UPD PKDtl Fail', 'us_english', 540
execute rdt.rdtAddMsg 77406, 10, '77406 UPD PKDtl Fail', 'us_english', 540
execute rdt.rdtAddMsg 77407, 10, '77407 Offset Fail   ', 'us_english', 540
execute rdt.rdtAddMsg 77408, 10, '77408 GetKey Fail   ', 'us_english', 540
execute rdt.rdtAddMsg 77409, 10, '77409 INSPackHdrFail', 'us_english', 540
execute rdt.rdtAddMsg 77410, 10, '77410 UPDPackDtlFail', 'us_english', 540
execute rdt.rdtAddMsg 77411, 10, '77411 GET LABEL Fail', 'us_english', 540
execute rdt.rdtAddMsg 77412, 10, '77412 INSPackDtlFail', 'us_english', 540
execute rdt.rdtAddMsg 77413, 10, '77413 INSPackDtlFail', 'us_english', 540
execute rdt.rdtAddMsg 77414, 10, '77414 Fail PackCfm  ', 'us_english', 540

-- SOS262231
execute rdt.rdtAddMsg 77415, 10, '77415^INS PINFO FAIL', 'us_english', 540
execute rdt.rdtAddMsg 77416, 10, '77416^UPD PINFO FAIL', 'us_english', 540
execute rdt.rdtAddMsg 77417, 10, '77417^SCAN IN FAIL',   'us_english', 540
execute rdt.rdtAddMsg 77418, 10, '77418^SCAN OUT FAIL',  'us_english', 540

