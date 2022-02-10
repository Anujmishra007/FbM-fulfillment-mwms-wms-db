--rdt_573ExtValidSP04
execute rdt.rdtDropMsg 176851 , 176900

execute rdt.rdtAddMsg 176851, 10,'176851 Mix PO Pallet', 'us_english', 573

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 176851 AND 176900

