--isp_1764LblDecode01
execute rdt.rdtdropmsg 110451 , 110500
GO
DECLARE @nFunc INT

SET @nFunc = 1764


execute rdt.rdtAddMsg 110451, 10, '10451^FoundExtraUCC ', 'us_english', 1764
execute rdt.rdtAddMsg 110452, 10, '10452^UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 110453, 10, '10453^UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 110454, 10, '10454^Need DropID   ', 'us_english', 1764
execute rdt.rdtAddMsg 110455, 10, '10455^UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 110455, 10, '10456^Scan-in Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 110457, 10, '10457^GetLabelNoFail', 'us_english', 1764
execute rdt.rdtAddMsg 110458, 10, '10458^INS PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 110459, 10, '10459^UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 110460, 10, '10460^UPDTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 110461, 10, '10461^UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 110462, 10, '10462^INS PKInf Fail', 'us_english', 1764
