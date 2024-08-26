--rdt_1650ExtValid06 
--FCR-574
execute rdt.rdtDropMsg 219351 , 219400

execute rdt.rdtAddMsg 219351, 10, '219351PlletScanned',    'us_english', 855, 0, '219351 this pallet was scanned'
execute rdt.rdtAddMsg 219352, 10, '219352DiffCBOLKey',    'us_english', 855, 0, '219352 Different CBOL Key'
execute rdt.rdtAddMsg 219353, 10, '219353DiffMBOLKey',    'us_english', 855, 0, '219353 Different MBOL Key'
execute rdt.rdtAddMsg 219354, 10, '219354NoPalletLeft',    'us_english', 855, 0, '219354 No Pallet Left'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 219351 AND 219400
