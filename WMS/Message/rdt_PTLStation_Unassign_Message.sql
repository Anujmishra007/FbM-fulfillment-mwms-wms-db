-- rdt_PTLStation_Unassign
execute rdt.rdtDropMsg 97251, 97300

execute rdt.rdtAddMsg 97251, 10, '97251^DEL LOG Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 97252, 10, '97252^DEL PTL Fail  ', 'us_english', 805

--WNS-15658
execute rdt.rdtAddMsg 97253, 10, '97253^UPD QLOG Fail ', 'us_english', 805
