-- nspItrnAddMove
execute rdt.rdtDropMsg 62001, 62010

execute rdt.rdtAddMsg 62001, 10, '62001 nspg_GetKey ItrnKey (nspItrnAddMove)', 'us_english'
execute rdt.rdtAddMsg 62002, 10, '62002 Execute nspGetPack Failed (nspItrnAddMove)', 'us_english'
execute rdt.rdtAddMsg 62003, 10, '62003 Execute nspUOMConv Failed (nspItrnAddMove)', 'us_english'
execute rdt.rdtAddMsg 62004, 10, '62004 MvExtVal Fail (nspItrnAddMove)', 'us_english'
execute rdt.rdtAddMsg 62005, 10, '62005 MvExtVal Fail (nspItrnAddMove)', 'us_english'
