SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[V_BartenderPrinters] AS 
SELECT ISNULL(Long,'')  AS ServerIP,
       ISNULL(PrinterID,'') AS PrinterID,
       ISNULL(WinPrinter,'') AS WinPrinter,
       PrinterGroup,
       c.Storerkey,
       c.UDF02 AS ServerName 
FROM CODELKUP c WITH (NOLOCK) 
LEFT JOIN rdt.rdtPrinter p WITH (NOLOCK) ON  p.Printergroup = c.storerkey
WHERE  ListName = 'TCPClient'
AND c.Short = 'BARTENDER'
GO
GRANT DELETE ON  [dbo].[V_BartenderPrinters] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_BartenderPrinters] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_BartenderPrinters] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_BartenderPrinters] TO [NSQL]
GO
