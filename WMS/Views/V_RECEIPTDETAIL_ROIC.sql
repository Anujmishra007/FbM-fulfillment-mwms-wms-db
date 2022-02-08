SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE VIEW [dbo].[V_RECEIPTDETAIL_ROIC]
AS
SELECT 	distinct rd.*,
	TransDate = CONVERT(datetime, CONVERT(char(10), i.adddate, 103), 103)
FROM 	RECEIPTDETAIL rd (nolock),
	ITRN i (nolock)
WHERE	i.sourcekey = rd.receiptkey+rd.receiptlinenumber and
	i.sourcetype like 'ntrReceiptDetail%'


GO
GRANT DELETE ON  [dbo].[V_RECEIPTDETAIL_ROIC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_RECEIPTDETAIL_ROIC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_RECEIPTDETAIL_ROIC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_RECEIPTDETAIL_ROIC] TO [NSQL]
GO
