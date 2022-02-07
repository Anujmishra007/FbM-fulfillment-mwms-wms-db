
--rdt_1805ExtUpdSP01
-- 112201 , 112250

exec rdt.rdtDropMsg 112201 , 112250
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1036

execute rdt.rdtAddMsg 112201 ,10, '12201^UpdDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 112202 ,10, '12202^UpdDPLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 112203 ,10, '12203^UpdDeviceProfileFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 112204 ,10, '12204^InsDPLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 112205 ,10, '12205^InsDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 112206 ,10, '12206^UpdPTLFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 112207 ,10, '12207^UpdDPLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 112208 ,10, '12208^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 112209 ,10, '12209^UpdDropIDFail', 'us_english',@nFunc
