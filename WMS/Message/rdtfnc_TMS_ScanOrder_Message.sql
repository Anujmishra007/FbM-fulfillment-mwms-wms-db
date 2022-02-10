
--rdtfnc_TMS_ScanOrder
-- 99401 - 99450

exec rdt.rdtDropMsg 99401 , 99450
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1185

execute rdt.rdtAddMsg 99401 ,10, '99401^OrderNoReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 99402 ,10, '99402^InvOrderNo', 'us_english',@nFunc
execute rdt.rdtAddMsg 99403 ,10, '99403^CartonNoReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 99404 ,10, '99404^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99405 ,10, '99405^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99406 ,10, '99406^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 99407 ,10, '99407^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99408 ,10, '99408^TrackingNoExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 99409 ,10, '99409^CartonNoExist', 'us_english',@nFunc

--(yeekung01)

execute rdt.rdtAddMsg 99410 ,10, '99410^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99411 ,10, '99411^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99412 ,10, '99412^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99413 ,10, '99413^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99414 ,10, '99414^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99415 ,10, '99415^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99416 ,10, '99416^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99417 ,10, '99417^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99418 ,10, '99418^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99419 ,10, '99419^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99420 ,10, '99420^InsTMSFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 99421 ,10, '99421^InsTMSFailed', 'us_english',@nFunc