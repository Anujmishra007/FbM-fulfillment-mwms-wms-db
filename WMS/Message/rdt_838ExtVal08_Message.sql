--rdt_838ExtVal08
execute rdt.rdtDropMsg 147501 , 147550

execute rdt.rdtAddMsg 147501, 10, '47501^Pick <> Pack',     'us_english', 838

SELECT * FROM RDT.RDTMsg AS r (NOLOCK) WHERE r.Message_ID BETWEEN 147501 AND 147550
