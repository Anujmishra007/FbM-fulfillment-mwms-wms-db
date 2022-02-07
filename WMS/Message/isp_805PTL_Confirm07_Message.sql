--isp_805PTL_Confirm07
--execute rdt.rdtdropmsg 123601 , 123650
GO
DECLARE @nFunc INT

SET @nFunc = 805

execute rdt.rdtAddMsg 123601, 10, '23601^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 123602, 10, '23602^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 123603, 10, '23603^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 123604, 10, '23604^INS PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 123605, 10, '23605^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 123606, 10, '23606^PKDtl changed ', 'us_english', 805
execute rdt.rdtAddMsg 123607, 10, '23607^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 123608, 10, '23608^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 123609, 10, '23609^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 123610, 10, '23610^nspg_GetKey   ', 'us_english', 805
execute rdt.rdtAddMsg 123611, 10, '23611^INS PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 123612, 10, '23612^INS RefKeyFail', 'us_english', 805
execute rdt.rdtAddMsg 123613, 10, '23613^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 123614, 10, '23614^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 123615, 10, '23615^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 123616, 10, '23616^PKDtl changed', 'us_english', 805
execute rdt.rdtAddMsg 123617, 10, '23617^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 123618, 10, '23618^PackCfm Fail', 'us_english', 805
execute rdt.rdtAddMsg 123619, 10, '23619^InsPHdrFail', 'us_english', 805
execute rdt.rdtAddMsg 123620, 10, '23620^InsPackDtlFail', 'us_english', 805
execute rdt.rdtAddMsg 123621, 10, '23621^UpdPackDtlFail', 'us_english', 805
execute rdt.rdtAddMsg 123622, 10, '23622^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 123623, 10, '23623^RDTNotinMatrixScreen', 'us_english', 805

