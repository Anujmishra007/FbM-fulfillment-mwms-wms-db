--rdt_PTLStation_Assign_WaveAutoID
--execute rdt.rdtdropmsg 118051 - 118100
GO
DECLARE @nFunc INT

SET @nFunc = 805

execute rdt.rdtAddMsg 118051, 10, '18051^WaveKeyReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 118052, 10, '18052^InvalidWaveKey','us_english',@nFunc
execute rdt.rdtAddMsg 118053, 10, '18053^WaveNoTask','us_english',@nFunc
execute rdt.rdtAddMsg 118054, 10, '18054^NoMorePosition','us_english',@nFunc
execute rdt.rdtAddMsg 118055, 10, '18055^InsertLogFail','us_english',@nFunc
execute rdt.rdtAddMsg 118056, 10, '18056^InsertLogFail','us_english',@nFunc

execute rdt.rdtAddMsg 118057, 10, '18057^WaveKeyReq','us_english',@nFunc
execute rdt.rdtAddMsg 118058, 10, '18058^WaveKey Assigned','us_english',@nFunc
execute rdt.rdtAddMsg 118059, 10, '18059^INS Log Fail','us_english',@nFunc
execute rdt.rdtAddMsg 118060, 10, '18060^Wave no task','us_english',@nFunc
execute rdt.rdtAddMsg 118061, 10, '18061^INS Log Fail','us_english',@nFunc
execute rdt.rdtAddMsg 118062, 10, '18062^Need CartonID','us_english',@nFunc
execute rdt.rdtAddMsg 118063, 10, '18063^UPD Log fail','us_english',@nFunc
execute rdt.rdtAddMsg 118064, 10, '18064^UPD Log fail','us_english',@nFunc
execute rdt.rdtAddMsg 118065, 10, '18065^LocReq','us_english',@nFunc
execute rdt.rdtAddMsg 118066, 10, '18066^InvalidLoc','us_english',@nFunc
execute rdt.rdtAddMsg 118067, 10, '18067^DelPTLLogFail','us_english',@nFunc
execute rdt.rdtAddMsg 118068, 10, '18068^DelPTLLogFail','us_english',@nFunc
execute rdt.rdtAddMsg 118069, 10, '18069^LocAssigned','us_english',@nFunc
execute rdt.rdtAddMsg 118070, 10, '18070^CartonIDAssign','us_english',@nFunc
execute rdt.rdtAddMsg 118071, 10, '18071^InvalidWaveKey','us_english',@nFunc
execute rdt.rdtAddMsg 118072, 10, '18072^WaveNotSame','us_english',@nFunc
execute rdt.rdtAddMsg 118073, 10, '18073^StationNotUnassign','us_english',@nFunc
execute rdt.rdtAddMsg 118074, 10, '18074^PTLNotAssign','us_english',@nFunc
execute rdt.rdtAddMsg 118075, 10, '18075^PTLNotAssign','us_english',@nFunc



