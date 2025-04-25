--rdt_896ReplConfirmSP01 
--235151 - 235200
execute rdt.rdtDropMsg 235151 , 235200	

execute rdt.rdtAddMsg 235151, 10, '235151ReplenBySKUQTYOn',  'us_english', 896, 0, '235151: Turn off ReplenBySKUQTY Config'
execute rdt.rdtAddMsg 235152, 10, '235152UCCNoEmpty',        'us_english', 896, 0, '235152: UCCNo is Empty'
execute rdt.rdtAddMsg 235153, 10, '235153^Upd RPL Fail',     'us_english', 896, 0, '235153: Update REPLENISHMENT Fail'
execute rdt.rdtAddMsg 235154, 10, '235154^Upd UCC Fail',     'us_english', 896, 0, '235154: Update UCC Fail'
execute rdt.rdtAddMsg 235155, 10, '235155^Upd PKD Fail',     'us_english', 896, 0, '235155: Update PICKDETAIL Fail'
execute rdt.rdtAddMsg 235156, 10, '235156^LooseIDLoc',       'us_english', 896, 0, '235156: ToLoc is the lose ID location'
execute rdt.rdtAddMsg 235157, 10, '235157^Upd PKD Fail',     'us_english', 896, 0, '235156: Update PICKDETAIL Fail'


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 235151 AND 235200	

