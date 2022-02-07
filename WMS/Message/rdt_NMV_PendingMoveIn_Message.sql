-- rdt_NMV_PendingMoveIn
exec rdt.rdtDropMsg 88251, 88300

execute rdt.rdtAddMsg 88251, 10, '88251^DEL ALL REC!!!', 'us_english'
execute rdt.rdtAddMsg 88252, 10, '88252^DEL NMV FAIL  ', 'us_english'
