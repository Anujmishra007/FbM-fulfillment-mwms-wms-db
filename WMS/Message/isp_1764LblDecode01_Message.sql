--isp_1764LblDecode01
execute rdt.rdtdropmsg 110401 , 110450
GO
DECLARE @nFunc INT

SET @nFunc = 1764

execute rdt.rdtAddMsg 110401, 10, '10401^UCC scanned',    'us_english',@nFunc
execute rdt.rdtAddMsg 110402, 10, '10402^BadTaskDtlKey',    'us_english',@nFunc
execute rdt.rdtAddMsg 110403, 10, '10403^Not an UCC',    'us_english',@nFunc
execute rdt.rdtAddMsg 110404, 10, '10404^Multi SKU UCC',    'us_english',@nFunc
execute rdt.rdtAddMsg 110405, 10, '10405^Bad UCC Status',    'us_english',@nFunc
execute rdt.rdtAddMsg 110406, 10, '10406^UCCLOCNotMatch',    'us_english',@nFunc
execute rdt.rdtAddMsg 110407, 10, '10407^UCCIDNotMatch',    'us_english',@nFunc
execute rdt.rdtAddMsg 110408, 10, '10408^UCCSKUNotMatch',    'us_english',@nFunc
execute rdt.rdtAddMsg 110409, 10, '10409^UCCTookByOther',    'us_english',@nFunc
execute rdt.rdtAddMsg 110410, 10, '10410^UPD PKDtl Fail',    'us_english',@nFunc
execute rdt.rdtAddMsg 110411, 10, '10411^PKDtl changed',    'us_english',@nFunc
execute rdt.rdtAddMsg 110412, 10, '10412^UCCLotNotMatch',    'us_english',@nFunc
