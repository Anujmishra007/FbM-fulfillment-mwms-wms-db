-- rdt_843ConfirmSP01
execute rdt.rdtDropMsg 169751,  169800

execute rdt.rdtAddMsg 169751, 10, '169751Invalid DropID', 'us_english', 843
execute rdt.rdtAddMsg 169752, 10, '169752Pick not done ', 'us_english', 843
execute rdt.rdtAddMsg 169753, 10, '169753DropID packed ', 'us_english', 843
execute rdt.rdtAddMsg 169754, 10, '169754DropID NotInPS', 'us_english', 843
execute rdt.rdtAddMsg 169755, 10, '169755DropID NotInPS', 'us_english', 843
execute rdt.rdtAddMsg 169756, 10, '169756DropID NotInPS', 'us_english', 843
execute rdt.rdtAddMsg 169757, 10, '169757DropID NotInPS', 'us_english', 843
execute rdt.rdtAddMsg 169758, 10, '169758InsPHdrFail   ', 'us_english', 843
execute rdt.rdtAddMsg 169759, 10, '169759UPD PKDtl Fail', 'us_english', 843
execute rdt.rdtAddMsg 169760, 10, '169760GenLabelNoFail', 'us_english', 843
execute rdt.rdtAddMsg 169761, 10, '169761GenLabelNoFail', 'us_english', 843
execute rdt.rdtAddMsg 169762, 10, '169762InsPackDtlFail', 'us_english', 843
execute rdt.rdtAddMsg 169763, 10, '169763UpdPackDtlFail', 'us_english', 843


SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 169751 and  169800