-- rdtfnc_TM_PutawayFrom
execute rdt.rdtDropMsg 79351, 79400

execute rdt.rdtAddMsg 79351, 10, '79351^LOC not match ', 'us_english', 1797
execute rdt.rdtAddMsg 79352, 10, '79352^ID not match  ', 'us_english', 1797
execute rdt.rdtAddMsg 79353, 10, '79353^LOC not match ', 'us_english', 1797
execute rdt.rdtAddMsg 79354, 10, '79354^NextTaskFncErr', 'us_english', 1797
execute rdt.rdtAddMsg 79355, 10, '79355^NextTaskScnErr', 'us_english', 1797
execute rdt.rdtAddMsg 79356, 10, '79356^Reason needed ', 'us_english', 1797
execute rdt.rdtAddMsg 79357, 10, '79357^InsSkipTskFail', 'us_english', 1797
execute rdt.rdtAddMsg 79358, 10, '79358^UpdSkipTskFail', 'us_english', 1797
execute rdt.rdtAddMsg 79359, 10, '79359^UpdSkipTskFail', 'us_english', 1797
execute rdt.rdtAddMsg 79360, 10, '79360^Need ID       ', 'us_english', 1797
execute rdt.rdtAddMsg 79361, 10, '79361^Need ToLOC    ', 'us_english', 1797

--WMS-10397
execute rdt.rdtAddMsg 79362, 10, '79362^InTransit Loc ', 'us_english', 1797
execute rdt.rdtAddMsg 79363, 10, '79363^OverWrite Fail', 'us_english', 1797

--WMS-11394
execute rdt.rdtAddMsg 79364, 10, '79364^OverWrite Fail', 'us_english', 1797