-- rdtfnc_TM_PutawayTo
execute rdt.rdtDropMsg 79201, 79250

execute rdt.rdtAddMsg 79201, 10, '79201^LOC not match ', 'us_english', 1796
execute rdt.rdtAddMsg 79202, 10, '79202^ID not match  ', 'us_english', 1796
execute rdt.rdtAddMsg 79203, 10, '79203^UCC needed    ', 'us_english', 1796
execute rdt.rdtAddMsg 79204, 10, '79204^UCC not on ID ', 'us_english', 1796
execute rdt.rdtAddMsg 79205, 10, '79205^LOC not match ', 'us_english', 1796
execute rdt.rdtAddMsg 79206, 10, '79206^NextTaskFncErr', 'us_english', 1796
execute rdt.rdtAddMsg 79207, 10, '79207^NextTaskScnErr', 'us_english', 1796
execute rdt.rdtAddMsg 79208, 10, '79208^Reason needed ', 'us_english', 1796
execute rdt.rdtAddMsg 79209, 10, '79209^UpdSkipTskFail', 'us_english', 1796
execute rdt.rdtAddMsg 79210, 10, '79210^UpdSkipTskFail', 'us_english', 1796

--WMS-11394
execute rdt.rdtAddMsg 79211, 10, '79211^OverWrite Fail', 'us_english', 1796
