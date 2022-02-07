--rdt_1641ExtValidSP05
execute rdt.rdtdropmsg 110651 , 110700
GO
DECLARE @nFunc INT

SET @nFunc = 1641

execute rdt.rdtAddMsg 110651, 10, '10651^Pallet closed',    'us_english',@nFunc
execute rdt.rdtAddMsg 110652, 10, '10652^CartonExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 110653, 10, '10653^SortCodeDiff',    'us_english',@nFunc
execute rdt.rdtAddMsg 110654, 10, '10654^InvalidCriteria',    'us_english',@nFunc
execute rdt.rdtAddMsg 110655, 10, '10655^SortCodeDiff',    'us_english',@nFunc

--WMS-11249
execute rdt.rdtAddMsg 110656, 10, '10656^Route Diff',    'us_english',@nFunc

