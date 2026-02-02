exec rdt.rdtdropmsg 238751 , 238800

--The following is based on the existed records in the database
execute rdt.rdtAddMsg 238751, 10, '238751Invalid Length', 'us_english'
execute rdt.rdtAddMsg 238752, 10, '238752Invalid Width', 'us_english'
execute rdt.rdtAddMsg 238753, 10, '238753Invalid Height', 'us_english'
execute rdt.rdtAddMsg 238754, 10, '238754Invalid Weight', 'us_english'
execute rdt.rdtAddMsg 238755, 10, '238755IUpd Pallet Err', 'us_english'
execute rdt.rdtAddMsg 238756, 10, '238756Pallet received', 'us_english'
execute rdt.rdtAddMsg 238757, 10, '238757Del PltDtl Err', 'us_english'
execute rdt.rdtAddMsg 238758, 10, '238758Del PltHdr Err', 'us_english'
execute rdt.rdtAddMsg 238759, 10, '238759INS PLDtl Err', 'us_english'

---For FCR840
SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 226651 AND 226700
