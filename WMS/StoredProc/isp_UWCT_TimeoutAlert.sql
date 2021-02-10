IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_UWCT_TimeoutAlert]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
BEGIN 
   DROP PROCEDURE [dbo].[isp_UWCT_TimeoutAlert]  
END
GO 

SET ANSI_NULLS ON  
GO
SET QUOTED_IDENTIFIER OFF
GO
 

/************************************************************************/  
/* Stored Procedure: isp_UWCT_TimeoutAlert                              */  
/* Creation Date: 11-Aug-2010                                           */  
/* Copyright: IDS                                                       */  
/* Written by: KHLim                                                    */  
/*                                                                      */  
/* Purpose: SOS#183620 [UNILEVER] - Staging server email alert          */  
/*                                                                      */  
/*                                                                      */  
/* Called By: ALT - UWCT_TimeoutAlert                                   */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Ver  Purposes                                   */  
/* 2011-11-02  KHLim01  1.1  change link server name                    */  
/* 2017-03-31  KHLim02  1.2  standardize link server name               */  
/************************************************************************/  
  
CREATE PROC [dbo].[isp_UWCT_TimeoutAlert]        
(  
   @recipientList   varchar(max),  
   @ccRecipientList varchar(max),  
   @nMin            int  
)  
AS  
BEGIN  
  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS ON  
   SET CONCAT_NULL_YIELDS_NULL OFF  
   SET ANSI_WARNINGS ON  
  
   DECLARE @cBody    NVARCHAR(MAX),    
           @cSubject NVARCHAR(255), -- max length of Subject field in Outlook   
           @nRowCnt  INT  
  
   SET @cSubject        = '[UNILEVER] - Staging server email alert - ' + @@serverName  
  
   SELECT TOP 10000 CTGUI, CTHFIL, CTSTS  
   INTO #tempUWCT  
   FROM [LINK_MYS_ULM_PROD].SAPPIPRDIDS.dbo.UWCT  -- KHLim01  KHLim02
   WHERE ((LEFT(CTGUI,1) <> 'M'  
     AND DATEDIFF(minute, CONVERT( datetime, '20' + SUBSTRING(CTGUI, 1, 6) + ' ' +   
                           SUBSTRING(CTGUI,  7, 2) + ':' + SUBSTRING(CTGUI,  9, 2) + ':' +   
                           SUBSTRING(CTGUI, 11, 2) ), GETDATE()) > @nMin)  
       OR (LEFT(CTGUI,1) =  'M'  
     AND DATEDIFF(minute, CONVERT( datetime, '20' + SUBSTRING(CTGUI, 2, 6) + ' ' +   
                           SUBSTRING(CTGUI,  8, 2) + ':' + SUBSTRING(CTGUI, 10, 2) + ':' +   
                           SUBSTRING(CTGUI, 12, 2) ), GETDATE()) > @nMin))  
     AND CTSTS = 'N'  
  
   SET @nRowCnt = @@ROWCOUNT  
  
   SET @cBody  = CAST(@nRowCnt AS VARCHAR(9)) + ' records found in staging server for more than ' +   
                 CAST(@nMin AS VARCHAR(9)) + ' minutes. Please check!'  
  
   IF EXISTS ( SELECT 1 FROM #tempUWCT )  
   BEGIN  
      SET @cBody = @cBody + N'<table border="1" cellspacing="0" cellpadding="5">' +  
          N'<tr bgcolor=silver><th>CTGUI</th><th>CTHFIL</th><th>CTSTS</th></tr>' +    
          CAST ( ( SELECT 'td/@align' = 'center',  
                          td = ISNULL(CAST(CTGUI AS char(15)),''), '',  
                          td = ISNULL(CAST(CTHFIL AS varchar(10)),''), '',  
                          td = ISNULL(CAST(CTSTS AS char(1)),'')  
                   FROM #tempUWCT  
              FOR XML PATH('tr'), TYPE  
          ) AS NVARCHAR(MAX) ) + N'</table>' ;  
  
      EXEC msdb.dbo.sp_send_dbmail   
         @recipients      = @recipientList,  
         @copy_recipients = @ccRecipientList,  
         @subject         = @cSubject,  
         @body            = @cBody,  
         @body_format     = 'HTML' ;  
   END  
  
   DROP TABLE #tempUWCT  
  
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_UWCT_TimeoutAlert] TO nSQL 
GO
