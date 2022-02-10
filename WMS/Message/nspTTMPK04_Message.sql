--nspTTMPK04
--rdt.rdtdropmsg 54551 , 54600

GO
DECLARE @nFunc INT

SET @nFunc = 0

execute rdt.rdtAddMsg 54551 ,10, '54551^NO DEVICE ID', 'us_english',@nFunc
execute rdt.rdtAddMsg 54552 ,10, '54552^Update to TaskDetail table failed', 'us_english',@nFunc
execute rdt.rdtAddMsg 54553 ,10, '54553^Could not Open Cursor_Eval02', 'us_english',@nFunc
execute rdt.rdtAddMsg 54554 ,10, '54554^UPDATE TaskDetail Failed', 'us_english',@nFunc







