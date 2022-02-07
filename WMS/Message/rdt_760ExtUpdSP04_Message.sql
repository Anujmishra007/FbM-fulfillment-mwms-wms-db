
--rdt_760ExtUpdSP04
-- 116301 - 116350

exec rdt.rdtDropMsg 116301 , 116350
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 760

execute rdt.rdtAddMsg 116301 ,10, '16301^InvDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 116302 ,10, '16302^InsPTLLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116303 ,10, '16303^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116304 ,10, '16304^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116305 ,10, '16305^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116306 ,10, '16306^GetKeyFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116307 ,10, '16307^InsPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116308 ,10, '16308^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116309 ,10, '16309^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116310 ,10, '16310^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116311 ,10, '16311^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116312 ,10, '16312^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116313 ,10, '16313^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 116314 ,10, '16314^InsPTSLogFail', 'us_english',@nFunc