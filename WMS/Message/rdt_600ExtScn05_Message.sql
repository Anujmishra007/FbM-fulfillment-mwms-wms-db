exec rdt.rdtdropmsg 240751 , 240800

execute rdt.rdtAddMsg 240751, 10, '240751 CaseAlreadyReceived', 'us_english', 600 , 0, '240751 CaseAlreadyReceived'
execute rdt.rdtAddMsg 240752, 10, '240752 InvalidBarcodeFormat', 'us_english', 600 , 0, '240752 InvalidBarcodeFormat'
execute rdt.rdtAddMsg 240753, 10, '240753 InvalidBarcodeFormat', 'us_english', 600 , 0, '240753 InvalidBarcodeFormat'

---For FCR840
SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 240751 and 240800