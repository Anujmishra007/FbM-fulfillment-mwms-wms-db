--isp_805PTL_Confirm06
--execute rdt.rdtdropmsg 120251 , 120300
GO
DECLARE @nFunc INT

SET @nFunc = 805

execute rdt.rdtAddMsg 120251, 10, '20251^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 120252, 10, '20252^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 120253, 10, '20253^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 120254, 10, '20254^INS PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 120255, 10, '20255^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 120256, 10, '20256^PKDtl changed ', 'us_english', 805
execute rdt.rdtAddMsg 120257, 10, '20257^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 120258, 10, '20258^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 120259, 10, '20259^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 120260, 10, '20260^nspg_GetKey   ', 'us_english', 805
execute rdt.rdtAddMsg 120261, 10, '20261^INS PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 120262, 10, '20262^INS RefKeyFail', 'us_english', 805
execute rdt.rdtAddMsg 120263, 10, '20263^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 120264, 10, '20264^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 120265, 10, '20265^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 120266, 10, '20266^PKDtl changed', 'us_english', 805
execute rdt.rdtAddMsg 120267, 10, '20267^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 120268, 10, '20268^nspg_getkeyFail', 'us_english', 805
execute rdt.rdtAddMsg 120269, 10, '20269^InsTaskDetFail', 'us_english', 805
execute rdt.rdtAddMsg 120270, 10, '20270^nspg_getkeyFail', 'us_english', 805
execute rdt.rdtAddMsg 120271, 10, '20271^UPD TaskDet Fail', 'us_english', 805