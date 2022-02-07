-- rdt_Putaway_PendingMoveIn (range 78101, 78150)
exec rdt.rdtDropMsg 78101, 78150

execute rdt.rdtAddMsg 78101, 10, '78101^UPD RPA Fail  ', 'us_english'
execute rdt.rdtAddMsg 78102, 10, '78102^UPD LLI Fail  ', 'us_english'
execute rdt.rdtAddMsg 78103, 10, '78103^UPD LLI Fail  ', 'us_english'
execute rdt.rdtAddMsg 78104, 10, '78104^UPD LLI Fail  ', 'us_english'
execute rdt.rdtAddMsg 78105, 10, '78105^UPD RPA Fail  ', 'us_english'
execute rdt.rdtAddMsg 78106, 10, '78106^INS ID Fail   ', 'us_english'
