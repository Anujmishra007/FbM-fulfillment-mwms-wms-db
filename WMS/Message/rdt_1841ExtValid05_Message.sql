execute rdt.rdtDropMsg 228551, 228600

execute rdt.rdtAddMsg 228551, 10, '228551 Mix SKU Not Allowed', 'us_english', 1841, 0, N'228551 Mix SKU Not Allowed'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 228551 AND 228600