
-- RDT Task Manager - Move (rdt_1765DecodeLBL01) Messages
-- **********************************************

execute rdt.rdtDropMsg 90601 , 90650

GO
DECLARE @nFunc INT

SET @nFunc = 1765


execute rdt.rdtAddMsg 90601, 10, '90601^Not an UCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 90602, 10, '90602^Multi SKU UCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 90603, 10, '90603^Bad UCC Status', 'us_english',@nFunc
execute rdt.rdtAddMsg 90604, 10, '90604^UCCLOCNotMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 90605, 10, '90605^UCCIDNotMatch  ', 'us_english',@nFunc
execute rdt.rdtAddMsg 90606, 10, '90606^UCCLOTNotMatch  ', 'us_english',@nFunc
execute rdt.rdtAddMsg 90607, 10, '90607^Over replenish  ', 'us_english',@nFunc
execute rdt.rdtAddMsg 90608, 10, '90608^UCCQTYNotMatch  ', 'us_english',@nFunc
execute rdt.rdtAddMsg 90609, 10, '90609^BadTaskDtlKey  ', 'us_english',@nFunc
execute rdt.rdtAddMsg 90610, 10, '90610^UCCNotMatch  ', 'us_english',@nFunc





                                  
                                  
                                  
                                  
                                  
