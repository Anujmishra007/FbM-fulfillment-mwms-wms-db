
-- rdtfnc_ResetUser (range 73501 - 73550)
execute rdt.rdtDropMsg 73501, 73550

execute rdt.rdtAddMsg 73501, 10, '73501^User required ', 'us_english'
execute rdt.rdtAddMsg 73502, 10, '73502^Invalid user  ', 'us_english'
execute rdt.rdtAddMsg 73503, 10, '73503^CantSelfReset ', 'us_english'
execute rdt.rdtAddMsg 73504, 10, '73504^User not login', 'us_english'
execute rdt.rdtAddMsg 73505, 10, '73505^UPD MobRecFail', 'us_english'
