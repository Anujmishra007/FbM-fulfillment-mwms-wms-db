--rdt_513ExtVal08
execute rdt.rdtdropmsg 160151 , 160200

execute rdt.rdtAddMsg 160151, 10, '60151^IDHas PendMvIn',    'us_english', 513

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 160151 AND 160200