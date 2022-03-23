SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [BI].[V_TH-YVESR_97_Check_B2S-ErrorStatus] as
select
A.WSInbound,
B.externorderkey AS Externorderkey_in_LFWMS,
	Case when B.externorderkey <> '' then 'Sucess'
when C.WSData <> ''  then 'Reject'
else 'Failed' end AS Sent_Status,
A.WSData  AS XML_to_Resend,
C.WSData

from
(
select distinct(substring(A.wsdata,136,13))as WSInbound,
A.WSdata
from DTS.wsinbound_log A with (nolock)
where A.storerkey ='YVESR'
and A.datastream ='4302' and A.Direction = 'I'
and A.adddate >='2021-07-22 11:00:31.217'
)A

Left join
(
Select B.externorderkey
from orders B with (nolock)
where B.storerkey ='YVESR'
and B.type ='B2S'
and B.doctype ='E'
and B.adddate >='2021-07-22 11:00:31.217'
--and B.status = '0'
)B
ON A.WSInbound = B.Externorderkey

Left join
(
select
distinct case
	when direction = 'O' then substring(wsdata,162,13)
	else '' end as Externorderkey,
AddDate,
WSData
from DTS.wsoutbound_log with (nolock)
where storerkey ='YVESR' and datastream ='4305'
and operationtype in('getLogisticOrderStatus_New','updLogisticOrderStatus_New')
and wsdata like '%WMS_REJECT%'
and  adddate >='2021-07-22 11:00:31.217'
)C  ON A.WSInbound = C.Externorderkey
GO
GRANT SELECT ON  [BI].[V_TH-YVESR_97_Check_B2S-ErrorStatus] TO [JReportRole]
GO

/*
EXEC AS LOGIN = 'JReportUserTH'
SELECT SUSER_SNAME()
SELECT * FROM [BI].[V_TH-YVESR_97_Check_B2S-ErrorStatus]

REVERT;
*/
