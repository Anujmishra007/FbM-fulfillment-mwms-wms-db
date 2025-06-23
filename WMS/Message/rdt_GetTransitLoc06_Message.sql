-- rdt_GetTransitLoc06
execute rdt.rdtdropmsg 214101 , 214150

execute rdt.rdtAddMsg 214101, 10, '214101^GetRightFail',    'us_english'
execute rdt.rdtAddMsg 214102, 10, '214102^NoAisle',         'us_english'
execute rdt.rdtAddMsg 214103, 10, '214103^NoCategory',      'us_english'
execute rdt.rdtAddMsg 214104, 10, '214104^WrongLocCat',     'us_english'
execute rdt.rdtAddMsg 214105, 10, '214105^NoMoveToLoc',     'us_english'
execute rdt.rdtAddMsg 214106, 10, '214106^NoMoveToLoc',     'us_english'
execute rdt.rdtAddMsg 214107, 10, '214107^LockLocFail',     'us_english'
execute rdt.rdtAddMsg 214108, 10, '214108^NoPickZone',      'us_english'

SELECT * FROM rdt.rdtMsg WHERE Message_ID BETWEEN 214101 AND 214150