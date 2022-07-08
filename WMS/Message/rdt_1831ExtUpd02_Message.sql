
--rdt_1831ExtUpd02
exec rdt.rdtDropMsg 180001  , 180050	


execute rdt.rdtAddMsg 180001 ,10, '180001DeleteLog Fail', 'us_english','1831'
execute rdt.rdtAddMsg 180002 ,10, '180002InvalidWave', 'us_english','1831'
execute rdt.rdtAddMsg 180003 ,10, '180003InsLogFail', 'us_english','1831'
execute rdt.rdtAddMsg 180004 ,10, '180004UpdLogFail', 'us_english','1831'

