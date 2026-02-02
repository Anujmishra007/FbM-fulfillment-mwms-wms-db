-- rdt_838ExtInfo02
-- FCR-9545
EXECUTE rdt.rdtDropMsg 254151, 254200

EXECUTE rdt.rdtAddMsg 254151 ,10, '254151 CondCodeNeed',       'us_english', 552, 0, '254151 Condition Code is needed'
EXECUTE rdt.rdtAddMsg 254152 ,10, '254152 BadCondCode',        'us_english', 552, 0, '254152 Bad Condition Code'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) where Message_ID BETWEEN 254151 AND 254200 ORDER BY Message_ID