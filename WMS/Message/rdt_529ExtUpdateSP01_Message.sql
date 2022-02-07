
--rdt_529ExtUpdateSP01
-- 84951 - 85000

exec rdt.rdtDropMsg 84951 , 85000
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 529

execute rdt.rdtAddMsg 84951 ,10, '84951^ToLabelReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 84952 ,10, '84952^FromLabelReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 84953 ,10, '84953^InsPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84954 ,10, '84954^UpdPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84955 ,10, '84955^UpdPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84956 ,10, '84956^DelPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84957 ,10, '84957^SplitPKDtlErr', 'us_english',@nFunc
execute rdt.rdtAddMsg 84958 ,10, '84958^OffsetError', 'us_english',@nFunc
execute rdt.rdtAddMsg 84959 ,10, '84959^InsPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84960 ,10, '84960^InsPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84961 ,10, '84961^UpdPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 84962 ,10, '84962^DelPackDtlFail', 'us_english',@nFunc