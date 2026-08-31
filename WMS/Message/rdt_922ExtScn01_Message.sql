-- rdt_922ExtScn01
-- FCR-11588
-- execute rdt.rdtDropMsg 264551, 264600
exec rdt.rdtDropMsg 264551, 264600

execute rdt.rdtAddMsg 264551, 10, '264551 Load Not MBOL', 'us_english', 922, 0, '264551: Load Not Populated to MBOL'
execute rdt.rdtAddMsg 264552, 10, '264552 Need Label No', 'us_english', 922, 0, '264552: Need Label No'
execute rdt.rdtAddMsg 264553, 10, '264553 Label Scanned', 'us_english', 922, 0, '264553: Label Already Scanned'
execute rdt.rdtAddMsg 264554, 10, '264554 BAD LBNo/DrpID', 'us_english', 922, 0, '264554: Bad LabelNo/DropID'
execute rdt.rdtAddMsg 264555, 10, '264555 NotPickConfirm', 'us_english', 922, 0, '264555: Not Pick Confirmed'
execute rdt.rdtAddMsg 264556, 10, '264556 BAD LBNo/DrpID', 'us_english', 922, 0, '264556: Bad LabelNo/DropID'
execute rdt.rdtAddMsg 264557, 10, '264557 NotPackConfirm', 'us_english', 922, 0, '264557: Not Pack Confirmed'
execute rdt.rdtAddMsg 264558, 10, '264558 ID NotInMBOL  ', 'us_english', 922, 0, '264558: ID Not In MBOL'
execute rdt.rdtAddMsg 264559, 10, '264559 ID NotInMBOL  ', 'us_english', 922, 0, '264559: ID Not In MBOL'
execute rdt.rdtAddMsg 264560, 10, '264560 ID NotInMBOL  ', 'us_english', 922, 0, '264560: ID Not In MBOL'
execute rdt.rdtAddMsg 264561, 10, '264561 ID NotInLoad  ', 'us_english', 922, 0, '264561: ID Not In Load'
execute rdt.rdtAddMsg 264562, 10, '264562 ID NotInLoad  ', 'us_english', 922, 0, '264562: ID Not In Load'
execute rdt.rdtAddMsg 264563, 10, '264563 ID NotInLoad  ', 'us_english', 922, 0, '264563: ID Not In Load'
execute rdt.rdtAddMsg 264564, 10, '264564 ID NotInOrder ', 'us_english', 922, 0, '264564: ID Not In Order'
execute rdt.rdtAddMsg 264565, 10, '264565 ID NotInOrder ', 'us_english', 922, 0, '264565: ID Not In Order'
execute rdt.rdtAddMsg 264566, 10, '264566 ID NotInOrder ', 'us_english', 922, 0, '264566: ID Not In Order'

execute rdt.rdtAddMsg 264568, 10, '264568 NotAllScanned ', 'us_english', 922, 0, '264568: Not All Cartons Scanned'
execute rdt.rdtAddMsg 264569, 10, '264569 Order CANCEL  ', 'us_english', 922, 0, '264569: Order Cancelled'

--UCC screen
execute rdt.rdtAddMsg 264567, 10, '264567 INS Truck Fail',      'us_english', 922, 0, '264567: Insert ScanToTruck Failed'
execute rdt.rdtAddMsg 264570, 10, '264570^UCCRequired',         'us_english', 922, 0, '264570: UCC is required'
execute rdt.rdtAddMsg 264571, 10, '264571^InvalidUCC',          'us_english', 922, 0, '264571: Invalid UCC'
execute rdt.rdtAddMsg 264572, 10, '264572^ScannedUCC',          'us_english', 922, 0, '264572: UCC was scanned'
execute rdt.rdtAddMsg 264573, 10, '264573^InvUCCStatus',        'us_english', 922, 0, '264573: Invalid UCC Status'
execute rdt.rdtAddMsg 264574, 10, '264574^UpdUCCFail',          'us_english', 922, 0, '264574: Update UCC Failed'
execute rdt.rdtAddMsg 264575, 10, '264575^UpdTruckFail',        'us_english', 922, 0, '264575: Update ScanToTruck Failed'
execute rdt.rdtAddMsg 264576, 10, '264576^ExceedTotalQty',      'us_english', 922, 0, '264576: Exceed total UCC Qty'
execute rdt.rdtAddMsg 264577, 10, '264577^UpdOrdFail',          'us_english', 922, 0, '264577: Update Order Failed'
execute rdt.rdtAddMsg 264578, 10, '264578^UpdMbolFail',         'us_english', 922, 0, '264578: Update MbolDetail Failed'
execute rdt.rdtAddMsg 264579, 10, '264579^OptRequired',         'us_english', 922, 0, '264579: Option is required'
execute rdt.rdtAddMsg 264580, 10, '264580^InvOption',           'us_english', 922, 0, '264580: Invalid option'
execute rdt.rdtAddMsg 264581, 10, '264581^InputRequired',       'us_english', 922, 0, '264581: RefNo1 and RefNo2 must have value'
execute rdt.rdtAddMsg 264582, 10, '264582^UpdMbolFail',         'us_english', 922, 0, '264582: Update Mbol Failed'
execute rdt.rdtAddMsg 264583, 10, '264583^ClosePltFail',        'us_english', 922, 0, '264583: Failed to close the pallet'
execute rdt.rdtAddMsg 264584, 10, '264584^UpdTruckFail',        'us_english', 922, 0, '264584: Update ScanToTruck Failed'
execute rdt.rdtAddMsg 264585, 10, '264585^UpdPackHdrFail',      'us_english', 922, 0, '264585: Update PackHeader Failed'

select * from rdt.rdtmsg (nolock) where message_id between 264551 and 264600
