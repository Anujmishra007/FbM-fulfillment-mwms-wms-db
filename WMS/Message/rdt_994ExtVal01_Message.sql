--rdt_994ExtVal01
--execute rdt.rdtdropmsg 280851, 280900
execute rdt.rdtDropMsg 280851, 280900

execute rdt.rdtAddMsg 280851, 10, '280851SortPendiente',    'us_english', 994, 0, '280851: Sort Pendiente'
--execute rdt.rdtAddMsg 280852, 10, '280852PickNotFound',     'us_english', 994, 0, '280852: PickDetail not found'
--execute rdt.rdtAddMsg 280853, 10, '280853PickNotFinished',  'us_english', 994, 0, '280853: Picking not finished'
execute rdt.rdtAddMsg 280854, 10, '280854PTWLogNotFound',   'us_english', 994, 0, '280854: PTW log not found for DropID'
execute rdt.rdtAddMsg 280855, 10, '280855InvalidOpt',       'us_english', 994, 0, '280855: ECOM: Invalid option'
execute rdt.rdtAddMsg 280856, 10, '280856InvalidOpt',       'us_english', 994, 0, '280856: Invalid option'
execute rdt.rdtAddMsg 280857, 10, '280857Opt2NotAllowed',   'us_english', 994, 0, '280857: Option 2 not allowed'

-- above messages are copied form rdt_838ExtVal41
execute rdt.rdtAddMsg 280858, 10, '280858OnlyPSNOAllowed',  'us_english', 994, 0, '280858: Only PSNO allowed'
execute rdt.rdtAddMsg 280859, 10, '280859Order&LoadEmpty',  'us_english', 994, 0, '280859: OrderKey and LoadKey both empty'
execute rdt.rdtAddMsg 280860, 10, '280860InsTPKDFail',      'us_english', 994, 0, '280860: Insert into @tPKD failed'
execute rdt.rdtAddMsg 280861, 10, '280861PickingPendiente', 'us_english', 994, 0, '280861: Picking Pendiente'
execute rdt.rdtAddMsg 280862, 10, '280862PackParcial',      'us_english', 994, 0, '280862: Pack Parcial'
execute rdt.rdtAddMsg 280863, 10, '280863PickDetailNotFnd', 'us_english', 994, 0, '280863: PickDetail not found'
execute rdt.rdtAddMsg 280864, 10, '280864InvalidPKDStatus', 'us_english', 994, 0, '280864: Invalid PickDetail Status'
execute rdt.rdtAddMsg 280865, 10, '280865SortInicioPTW',    'us_english', 994, 0, '280865: Sort Inicio en PTW'
execute rdt.rdtAddMsg 280866, 10, '280866ECOMQtyMismatch',  'us_english', 994, 0, '280866: ECOM SKU qty mismatch'
execute rdt.rdtAddMsg 280867, 10, '280867SortInicioPTW',    'us_english', 994, 0, '280867: Sort Inicio en PTW'
execute rdt.rdtAddMsg 280868, 10, '280868ESC para cerrar',  'us_english', 994, 0, '280868: ESC para cerrar'

select * from rdt.rdtmsg (nolock) where message_id between 280851 and 280900
