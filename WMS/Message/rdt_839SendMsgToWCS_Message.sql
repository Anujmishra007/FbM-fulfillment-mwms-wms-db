--rdt_839SendMsgToWCS
exec rdt.rdtdropmsg 249401 , 249450

--The following is based on the existed records in the database
execute rdt.rdtAddMsg 249401, 10, '249401 Not allow mix SKU', 'us_english', 600 , 0, '203751 Not allow mix SKU'
execute rdt.rdtAddMsg 249402, 10, '249402 Not allow mix SKU', 'us_english', 600 , 0, '249402 Not allow mix SKU'
execute rdt.rdtAddMsg 249403, 10, '249403 Not allow mix SKU', 'us_english', 600 , 0, '249403 Not allow mix SKU'
execute rdt.rdtAddMsg 249404, 10, '249404 Not allow mix SKU', 'us_english', 600 , 0, '249404 Not allow mix SKU'
execute rdt.rdtAddMsg 249405, 10, '249405 UPD ORDERS Fail'  , 'us_english', 600 , 0, '249405 UPD ORDERS Fail'
execute rdt.rdtAddMsg 249406, 10, '249406 INS TLog2 Fail'   , 'us_english', 600 , 0, '249406 INS TLog2 Fail'

--249401   ENG   DSP   249401 Not allow mix SKU      0   600      249401 Not allow mix SKU    no ref
--249402   ENG   DSP   249402 Not allow mix SKU      0   600      249402 Not allow mix SKU    no ref
--249403   ENG   DSP   249403 Not allow mix SKU      0   600      249403 Not allow mix SKU    no ref
--249404   ENG   DSP   249404 Not allow mix SKU      0   600      249404 Not allow mix SKU    no ref
--249405   ENG   DSP   249405 UPD ORDERS Fail        0   600      249405 Update ORDERS Fail   no ref
--249406   ENG   DSP   249406 INS TLog2 Fail         0   600      249409 INS TLog2 Fail       used

---For FCR771
---No addtional message are required

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 249401 AND 249450
