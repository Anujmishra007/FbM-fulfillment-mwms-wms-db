-- rdt_VAPUnCasingConfirm
exec rdt.rdtDropMsg 59901 , 59950

execute rdt.rdtAddMsg 59901, 10, '59901^INS UNCASE ERR',    'us_english', 1151
execute rdt.rdtAddMsg 59902, 10, '59902^UPD UNCASE ERR',    'us_english', 1151
execute rdt.rdtAddMsg 59903, 10, '59903^UPD TASK FAIL',     'us_english', 1151