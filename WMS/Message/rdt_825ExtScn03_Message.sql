
--rdt_825ExtScn03
--FCR-14856

EXECUTE rdt.rdtDropMsg 280551, 280600

EXECUTE rdt.rdtAddMsg 280551, 10, '280551^TL2KeyGenFail',      'us_english', 825, 0, '280551 TransmitLog2 key generation failed'
EXECUTE rdt.rdtAddMsg 280552, 10, '280552^RcptDtlNotFound',    'us_english', 825, 0, '280552 Receipt detail not found for pallet'
EXECUTE rdt.rdtAddMsg 280553, 10, '280553^TL2InsertGRNFail',   'us_english', 825, 0, '280553 TransmitLog2 insert failed (GRN)'
EXECUTE rdt.rdtAddMsg 280554, 10, '280554^TL2InsertPatchFail', 'us_english', 825, 0, '280554 TransmitLog2 insert failed (GRN Patch)'
EXECUTE rdt.rdtAddMsg 280555, 10, '280555^NoInvFound',         'us_english', 825, 0, '280555 Inventory not found for PalletKey'

SELECT * FROM rdt.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 280551 AND 280600
