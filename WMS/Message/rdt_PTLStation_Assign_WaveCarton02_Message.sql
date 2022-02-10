--rdt_PTLStation_Assign_WaveCarton02
--execute rdt.rdtdropmsg 123501 - 123550
GO
DECLARE @nFunc INT

SET @nFunc = 805

execute rdt.rdtAddMsg 123501, 10, '23501^WaveKeyReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 123502, 10, '23502^InvalidWaveKey','us_english',@nFunc
execute rdt.rdtAddMsg 123503, 10, '23503^StationNotUnassign','us_english',@nFunc
execute rdt.rdtAddMsg 123504, 10, '23504^WaveNoTask','us_english',@nFunc
execute rdt.rdtAddMsg 123505, 10, '23505^InsertLogFail','us_english',@nFunc
execute rdt.rdtAddMsg 123506, 10, '23506^LocReq','us_english',@nFunc
execute rdt.rdtAddMsg 123507, 10, '23507^InvalidLoc','us_english',@nFunc
execute rdt.rdtAddMsg 123508, 10, '23508^Need CartonID','us_english',@nFunc
execute rdt.rdtAddMsg 123509, 10, '23509^CartonID used','us_english',@nFunc
execute rdt.rdtAddMsg 123510, 10, '23510^LocAssigned','us_english',@nFunc
execute rdt.rdtAddMsg 123511, 10, '23511^UPD Log fail','us_english',@nFunc
execute rdt.rdtAddMsg 123512, 10, '23512^Invalid Format','us_english',@nFunc




