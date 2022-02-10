--rdt_VerifySKU_Case01
execute rdt.rdtDropMsg 56851, 56900

execute rdt.rdtAddMsg 56851, 10, '56851^Bad Case',        'us_english'
execute rdt.rdtAddMsg 56852, 10, '56852^NEW CASE FAIL',   'us_english'
execute rdt.rdtAddMsg 56853, 10, '56853^UPD CASE FAIL',   'us_english'
execute rdt.rdtAddMsg 56854, 10, '56854^UPD CASE FAIL',   'us_english'
execute rdt.rdtAddMsg 56855, 10, '56855^UPD CASE FAIL',   'us_english'