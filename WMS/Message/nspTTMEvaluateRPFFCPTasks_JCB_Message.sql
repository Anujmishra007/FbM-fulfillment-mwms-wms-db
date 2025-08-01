-- FCR-5727
execute rdt.rdtdropmsg 239801 , 239850

execute rdt.rdtAddMsg 239801, 10, '239801^UpdTaskDetFail',     'us_english', 1764, 0, '239801 Update TaskDetail Fail'
execute rdt.rdtAddMsg 239802, 10, '239802^PopLateFail',        'us_english', 1764, 0, '239802 Populate @tFCPRPFTaskCandidate Fail'
execute rdt.rdtAddMsg 239803, 10, '239803^PopLateFail',        'us_english', 1764, 0, '239803 Populate @tFCPRPFTaskCandidate Fail'
execute rdt.rdtAddMsg 239804, 10, '239804^PopLateFail',        'us_english', 1764, 0, '239804 Populate @tFCPRPFTaskCandidate Fail'
execute rdt.rdtAddMsg 239805, 10, '239805^PopLateFail',        'us_english', 1764, 0, '239805 Populate @tFCPRPFTaskCandidate Fail'
execute rdt.rdtAddMsg 239806, 10, '239806^PopLateFail',        'us_english', 1764, 0, '239806 Populate @tFCPRPFTaskDeliveryDate Fail'
execute rdt.rdtAddMsg 239807, 10, '239807^PopLateFail',        'us_english', 1764, 0, '239807 Populate @tTaskCandidate Fail'
execute rdt.rdtAddMsg 239808, 10, '239808^PopLateFail',        'us_english', 1764, 0, '239808 Populate @tFPTaskCandidate Fail'
execute rdt.rdtAddMsg 239809, 10, '239809^UpdFail',            'us_english', 1764, 0, '239809 Update @tTaskCandidate Fail'
execute rdt.rdtAddMsg 239810, 10, '239810^UpdFail',            'us_english', 1764, 0, '239810 Update @tTaskCandidate Fail'
execute rdt.rdtAddMsg 239811, 10, '239811^UpdFail',            'us_english', 1764, 0, '239811 Update @tTaskCandidate Fail'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 239801 AND 239850