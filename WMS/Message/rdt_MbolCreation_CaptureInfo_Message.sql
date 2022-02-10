--rdt_MbolCreation_CaptureInfo
exec rdt.rdtdropmsg 173151, 173200

execute rdt.rdtAddMsg 173151, 10, '173151Need data     ', 'us_english', 1856
execute rdt.rdtAddMsg 173152, 10, '173151Invalid format', 'us_english', 1856
execute rdt.rdtAddMsg 173153, 10, '173151Invalid value ', 'us_english', 1856

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 173151 AND 173200
