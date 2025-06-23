--rdt_600GetRcvInfo10  226601 - 226650
exec rdt.rdtdropmsg 226601 , 226650

--The following is based on the existed records in the database
execute rdt.rdtAddMsg 226601, 10, '226601invalid config', 'us_english', 600 , 0, '226601 Invalid config of DistinctLottableDefault'

---For FCR840
SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 226601 AND 226650
