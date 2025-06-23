--rdt_600ExtScn06  226651 - 226700
exec rdt.rdtdropmsg 226651 , 226700

--The following is based on the existed records in the database
execute rdt.rdtAddMsg 226651, 10, '226651Invalid Lottable', 'us_english', 600 , 0, '226651 Invalid Lottable'

---For FCR840
SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 226651 AND 226700
