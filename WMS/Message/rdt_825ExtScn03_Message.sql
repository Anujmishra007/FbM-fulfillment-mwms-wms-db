
--rdt_825ExtScn03
--FCR-14856

EXECUTE rdt.rdtDropMsg 280551, 280600

EXECUTE rdt.rdtAddMsg 280551, 10, '280551^NoInvFound',          'us_english', 825, 0, '280551 Inventory not found for PalletKey'
EXECUTE rdt.rdtAddMsg 280552, 10, '280552^TL2KeyGenFail',       'us_english', 825, 0, '280552 TransmitLog2 key generation failed'
EXECUTE rdt.rdtAddMsg 280553, 10, '280553^RcptDtlNotFound',     'us_english', 825, 0, '280553 Receipt detail not found for pallet'
EXECUTE rdt.rdtAddMsg 280554, 10, '280554^MultTL2Found',        'us_english', 825, 0, '280554 Multiple TransmitLog2 records found (GRN)'
EXECUTE rdt.rdtAddMsg 280555, 10, '280555^TL2UpdateGRNFail',    'us_english', 825, 0, '280555 TransmitLog2 update failed (GRN)'
EXECUTE rdt.rdtAddMsg 280556, 10, '280556^TL2InsertGRNFail',    'us_english', 825, 0, '280556 TransmitLog2 insert failed (GRN)'
EXECUTE rdt.rdtAddMsg 280557, 10, '280557^TL2InsertPatchFail',  'us_english', 825, 0, '280557 TransmitLog2 insert failed (GRN Patch)'

SELECT * FROM rdt.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 280551 AND 280600
