exec rdt.rdtDropMsg 267151,267200

-- 267151: Split receipt line failed
execute rdt.rdtAddMsg 267151, 10, 'Split line failed', 'us_english', 600

-- 267152: Update CaseID failed for PVAR item
execute rdt.rdtAddMsg 267152, 10, 'Update CaseID fail', 'us_english', 600

-- 267153: Update CaseID failed for non-PVAR item
execute rdt.rdtAddMsg 267153, 10, 'Update CaseID fail', 'us_english', 600


SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 267151 AND  267200

