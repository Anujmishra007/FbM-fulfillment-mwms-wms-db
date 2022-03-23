SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_LABELLIST]
AS
SELECT [LabelName]
, [LabelDesc]
, [LabelType]
, [DefaultPrinter]
, [PrinterType]
, [DWName]
, [PredownloadFile]
, [DownloadFile]
, [UseTimer]
, [TimerInterval]
, [Resolution]
, [LayOut]
, [PrintPos]
, [Port]
, [ClearPrintBuffer]
, [LLMSUB]
FROM [LABELLIST] (NOLOCK)
GO
GRANT DELETE ON  [dbo].[V_LABELLIST] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_LABELLIST] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_LABELLIST] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_LABELLIST] TO [NSQL]
GO
