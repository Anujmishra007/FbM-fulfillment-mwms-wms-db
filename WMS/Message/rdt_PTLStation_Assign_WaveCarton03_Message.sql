-- rdt_PTLStation_Assign_WaveCarton03
execute rdt.rdtDropMsg 172901, 172950	

execute rdt.rdtAddMsg 172901, 10, '172901WaveKeyReq', 'us_english', 805
execute rdt.rdtAddMsg 172902, 10, '172902InvalidWaveKey','us_english', 805
execute rdt.rdtAddMsg 172903, 10, '172903WaveNotSame', 'us_english', 805
execute rdt.rdtAddMsg 172904, 10, '172904WaveNoTask','us_english', 805
execute rdt.rdtAddMsg 172905, 10, '172905InsLogFail', 'us_english', 805
execute rdt.rdtAddMsg 172906, 10, '172906NeedCartonID','us_english', 805
execute rdt.rdtAddMsg 172907, 10, '172907LocAssigned', 'us_english', 805
execute rdt.rdtAddMsg 172908, 10, '172908CartonIDAssign','us_english', 805
execute rdt.rdtAddMsg 172909, 10, '172909UpdLogFail', 'us_english', 805

--wms17691
execute rdt.rdtAddMsg 172910, 10, '172910InvalidCartonid', 'us_english', 805