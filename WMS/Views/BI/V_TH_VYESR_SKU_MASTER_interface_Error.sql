SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [BI].[V_TH_VYESR_SKU_MASTER_interface_Error] as
select distinct DataStream, FileName, Status, ErrMsg, convert(varchar, AddDate, 103) as AddDate,
	   convert(varchar, EditDate, 103) as EditDate
from DTS.IN_LINE
where FileName like 'EYVES_SKU_%'
and Status = '5' and len(errMsg) > 10 
and Convert(Date, AddDate, 103) = Convert(Date, GetDate(), 103)
GO
GRANT SELECT ON  [BI].V_TH_VYESR_SKU_MASTER_interface_Error TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JReportUserTH'
SELECT SUSER_SNAME()
SELECT * FROM [BI].[V_TH_VYESR_SKU_MASTER_interface_Error]

REVERT;
*/