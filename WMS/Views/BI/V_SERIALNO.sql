SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [BI].[V_SERIALNO] AS   
SELECT SerialNoKey
, OrderKey
, OrderLineNumber
, StorerKey
, SKU
, SerialNo
, Qty
, AddWho
, AddDate
, Status
, LotNo
, EditDate
, EditWho
, ID
, ExternStatus
, PickSlipNo
, CartonNo
, LabelLine
, UserDefine01
, UserDefine02
, UserDefine03
, UserDefine04
, UserDefine05
, ArchiveCop
, TrafficCop=CAST(TrafficCop AS NVARCHAR)   
   FROM [SERIALNO] WITH (NOLOCK)   
GO
GRANT SELECT ON  [BI].[V_SERIALNO] TO [JReportRole]
GO
