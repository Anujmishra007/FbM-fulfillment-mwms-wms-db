--rdt_842ExtUpdSP04
exec rdt.rdtDropMsg 130451 , 130500

execute rdt.rdtAddMsg 130451 ,10, '30451^InvDropID',        'us_english',842
execute rdt.rdtAddMsg 130452 ,10, '30452^UpdEcommFail',     'us_english',842
execute rdt.rdtAddMsg 130453 ,10, '30453^PickNotComplete',  'us_english',842
execute rdt.rdtAddMsg 130454 ,10, '30454^NoRecToProcess',   'us_english',842
execute rdt.rdtAddMsg 130455 ,10, '30455^SKuNotIntote',     'us_english',842
execute rdt.rdtAddMsg 130456 ,10, '30456^QtyExceeded',      'us_english',842
execute rdt.rdtAddMsg 130457 ,10, '30457^InsPickHdrFail',   'us_english',842
execute rdt.rdtAddMsg 130458 ,10, '30458^UpdPickDetFail',   'us_english',842
execute rdt.rdtAddMsg 130459 ,10, '30459^InsPickInfoFail',  'us_english',842
execute rdt.rdtAddMsg 130460 ,10, '30460^CreatePHdrFail',   'us_english',842
execute rdt.rdtAddMsg 130461 ,10, '30461^NoLabelNoGen',     'us_english',842
execute rdt.rdtAddMsg 130462 ,10, '30462^NoLabelNoGen',     'us_english',842
execute rdt.rdtAddMsg 130463 ,10, '30463^UpdEcommFail',     'us_english',842
execute rdt.rdtAddMsg 130464 ,10, '30464^InsPackDetFail',   'us_english',842
execute rdt.rdtAddMsg 130465 ,10, '30465^UpdPackDetFail',   'us_english',842
execute rdt.rdtAddMsg 130466 ,10, '30466^UpdPickDetFull',   'us_english',842
execute rdt.rdtAddMsg 130467 ,10, '30467^UpdOrderFail',     'us_english',842
execute rdt.rdtAddMsg 130468 ,10, '30468^UpdOrderFail',     'us_english',842
execute rdt.rdtAddMsg 130469 ,10, '30469^UpdOrdFail',       'us_english',842
execute rdt.rdtAddMsg 130470 ,10, '30470^UpdPackDetFail',   'us_english',842
execute rdt.rdtAddMsg 130471 ,10, '30471^UpdEcommFail',     'us_english',842
execute rdt.rdtAddMsg 130472 ,10, '30472^UpdDroIDFail',     'us_english',842
execute rdt.rdtAddMsg 130473 ,10, '30473^UpdEcommFail',     'us_english',842
execute rdt.rdtAddMsg 130474 ,10, '30474^InvalidOption',    'us_english',842
execute rdt.rdtAddMsg 130475 ,10, '30475^PickNotDone',      'us_english',842
execute rdt.rdtAddMsg 130476 ,10, '30476^PickNotComplete',  'us_english',842
execute rdt.rdtAddMsg 130477 ,10, '30477^NoRecToProcess',   'us_english',842
execute rdt.rdtAddMsg 130478 ,10, '30478^UpdCtnTrackErr',   'us_english',842

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 130451 AND 130500
