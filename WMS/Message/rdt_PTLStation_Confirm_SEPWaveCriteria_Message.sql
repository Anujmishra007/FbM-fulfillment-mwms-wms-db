--rdt_PTLStation_Confirm_SEPWaveCriteria
execute rdt.rdtdropmsg 157201 , 157250	

execute rdt.rdtAddMsg 157201, 10, '57201^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 157202, 10, '57202^InsPHdrFail',      'us_english', 805
execute rdt.rdtAddMsg 157203, 10, '57203^InsPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 157204, 10, '57204^UpdPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 157205, 10, '57205^PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 157206, 10, '57206^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157207, 10, '57207^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157208, 10, '57208^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 157209, 10, '57209^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 157210, 10, '57210^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 157211, 10, '57211^INS PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 157212, 10, '57212^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 157213, 10, '57213^InsPHdrFail',      'us_english', 805
execute rdt.rdtAddMsg 157214, 10, '57214^InsPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 157215, 10, '57215^UpdPackDtlFail',   'us_english', 805
execute rdt.rdtAddMsg 157216, 10, '57216^PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 157217, 10, '57217^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157218, 10, '57218^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157219, 10, '57219^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157220, 10, '57220^nspg_GetKey',      'us_english', 805
execute rdt.rdtAddMsg 157221, 10, '57221^INS PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157222, 10, '57222^INS RefKeyFail',   'us_english', 805
execute rdt.rdtAddMsg 157223, 10, '57223^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157224, 10, '57224^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157225, 10, '57225^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157226, 10, '57226^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157227, 10, '57227^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157228, 10, '57228^nspg_GetKey',      'us_english', 805
execute rdt.rdtAddMsg 157229, 10, '57229^INS PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157230, 10, '57230^INS RefKeyFail',   'us_english', 805
execute rdt.rdtAddMsg 157231, 10, '57231^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157232, 10, '57232^UPD PKDtl Fail',   'us_english', 805
execute rdt.rdtAddMsg 157233, 10, '57233^UPD Log Fail',     'us_english', 805
execute rdt.rdtAddMsg 157234, 10, '57234^UPD PTL Fail',     'us_english', 805
execute rdt.rdtAddMsg 157235, 10, '57235^PKDtl changed',    'us_english', 805
execute rdt.rdtAddMsg 157236, 10, '57236^UPD PKDtl Fail',   'us_english', 805

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 157201 AND 157250	
