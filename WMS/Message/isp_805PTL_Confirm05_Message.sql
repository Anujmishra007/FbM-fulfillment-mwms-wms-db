--isp_805PTL_Confirm05
--execute rdt.rdtdropmsg 118151 , 118200
GO
DECLARE @nFunc INT

SET @nFunc = 805

execute rdt.rdtAddMsg 118151, 10, '18151^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 118152, 10, '18152^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 118153, 10, '18153^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 118154, 10, '18154^INS PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 118155, 10, '18155^UPD PTL Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 118156, 10, '18156^PKDtl changed ', 'us_english', 805
execute rdt.rdtAddMsg 118157, 10, '18157^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 118158, 10, '18158^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 118159, 10, '18159^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 118160, 10, '18160^nspg_GetKey   ', 'us_english', 805
execute rdt.rdtAddMsg 118161, 10, '18161^INS PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 118162, 10, '18162^INS RefKeyFail', 'us_english', 805
execute rdt.rdtAddMsg 118163, 10, '18163^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 118164, 10, '18164^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 118165, 10, '18165^UPD PKDtl Fail', 'us_english', 805
execute rdt.rdtAddMsg 118166, 10, '18166^PKDtl changed', 'us_english', 805
execute rdt.rdtAddMsg 118167, 10, '18167^UPD PKDtl Fail', 'us_english', 805

