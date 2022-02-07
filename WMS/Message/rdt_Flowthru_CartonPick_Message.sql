--rdt_Flowthru_CartonPick
execute rdt.rdtdropmsg 85551, 85600    

execute rdt.rdtAddMsg 85551, 10, '85551^INS ORDTL FAIL', 'us_english', 588
execute rdt.rdtAddMsg 85552, 10, '85552^UPD ORDTL FAIL', 'us_english', 588
execute rdt.rdtAddMsg 85553, 10, '85553^GET PDKEY FAIL', 'us_english', 588
execute rdt.rdtAddMsg 85554, 10, '85554^INS PKDTL FAIL', 'us_english', 588
execute rdt.rdtAddMsg 85555, 10, '85555^UPD PKDTL FAIL', 'us_english', 588
