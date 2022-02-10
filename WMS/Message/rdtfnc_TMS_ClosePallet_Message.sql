-- rdtfnc_TMS_ClosePallet
-- 109051 - 109100

exec rdt.rdtDropMsg 109051 , 109100
-- ************************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1188



execute rdt.rdtAddMsg 109051, 10, '09051^LabelPrnterReq',    'us_english', @nFunc
execute rdt.rdtAddMsg 109052, 10, '09052^PalletIDReq',    'us_english', @nFunc
execute rdt.rdtAddMsg 109053, 10, '09053^PalletNotExist',    'us_english', @nFunc
execute rdt.rdtAddMsg 109054, 10, '09054^InvPLTStatus',    'us_english', @nFunc
execute rdt.rdtAddMsg 109055, 10, '09055^InvalidQTY',    'us_english', @nFunc
execute rdt.rdtAddMsg 109056, 10, '09056^HeightOverLimit',    'us_english', @nFunc
execute rdt.rdtAddMsg 109057, 10, '09057^InvalidQTY',    'us_english', @nFunc
execute rdt.rdtAddMsg 109058, 10, '09058^WeightOverLimit',    'us_english', @nFunc
execute rdt.rdtAddMsg 109059, 10, '09059^LocReq',    'us_english', @nFunc
execute rdt.rdtAddMsg 109060, 10, '09060^InvalidLoc',    'us_english', @nFunc

