--rdt_607ExtVal07
--UWP-26373
exec rdt.rdtDropMsg 228101 , 228150	

execute rdt.rdtAddMsg 228101, 10, '228101CancelDatePassed',          'us_english', 607, 0, '228101Cancel Date Passed'
execute rdt.rdtAddMsg 228102, 10, '228102OverReceive',               'us_english', 607

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 228101 AND 228150


