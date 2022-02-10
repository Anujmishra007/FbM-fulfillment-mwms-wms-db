
--rdtfnc_UserAttendance
-- 95001 - 95050

exec rdt.rdtDropMsg 95001 , 95050
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 704

execute rdt.rdtAddMsg 95001 ,10, '95001^UserIDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 95002 ,10, '95002^LocReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 95003 ,10, '95003^InsertLogErr', 'us_english',@nFunc
execute rdt.rdtAddMsg 95004 ,10, '95004^UpdateLogErr', 'us_english',@nFunc
execute rdt.rdtAddMsg 95005 ,10, '95005^AttendanceExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 95006 ,10, '95006^UpdateLogErr', 'us_english',@nFunc
execute rdt.rdtAddMsg 95007 ,10, '95007^InvalidLoc', 'us_english',@nFunc
execute rdt.rdtAddMsg 95008 ,10, '95008^InvalidUserID', 'us_english',@nFunc






