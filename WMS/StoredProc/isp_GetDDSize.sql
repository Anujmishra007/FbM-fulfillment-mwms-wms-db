IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetDDSize]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetDDSize]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: isp_GetDDSize                                      */
/* Creation Date: 9-Aug-2010                                            */
/* Copyright: IDS                                                       */
/* Written by: KHLim                                                    */
/*                                                                      */
/* Purpose: get Disk Drive's space                                      */
/*                                                                      */
/*                                                                      */
/* Called By: ALT - Low Disk Space Notification                         */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author  Ver  Purposes                                    */
/* 2010-08-09  KHLim   1.0  initial revision                            */
/* 2011-11-30  KHLim01 1.1  parameter changes                           */
/* 2014-12-23  KHLim   1.2  include free percentage  (KHLim02)          */
/* 2015-06-17  KHLim   1.3  SMS when critically low  (KHLim04)          */
/************************************************************************/

CREATE PROC [dbo].[isp_GetDDSize]      
(
   @cListTo          NVARCHAR(max),
   @cListCc          NVARCHAR(max),
   @cDriveLetterList NVARCHAR(50),
   @nCriticalMB      int,
   @nCriticalPct     int = 10  --KHLim02
   ,@cMobile1        NVARCHAR(30) = ''  --KHLim04
   ,@cMobile2        NVARCHAR(30) = ''
   ,@cMobile3        NVARCHAR(30) = ''
)
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS ON
   SET ANSI_WARNINGS ON
   SET CONCAT_NULL_YIELDS_NULL OFF

   -- Start getting total disk size and free size   
   DECLARE @nDrive   TINYINT,  
           @cBody    NVARCHAR(MAX),  
           @cSubject NVARCHAR(255),
           @SQL      NVARCHAR(4000)

   SET @nDrive = 97  
   SET @cSubject = 'Low Disk Space Notification - ' + @@serverName
   SET @cBody = ''

   -- Setup Staging Area  
   DECLARE @Drives TABLE  
   (
      Drive NVARCHAR(1),
      Info  NVARCHAR(80)
   )

   WHILE @nDrive <= 122
   BEGIN
      SET @SQL = 'EXEC XP_CMDSHELL ''fsutil volume diskfree ' + master.dbo.fnc_GetCharASCII(@nDrive) + ':'''

      INSERT @Drives
      (
         Info
      )
      EXEC (@SQL)

      UPDATE @Drives
      SET Drive = master.dbo.fnc_GetCharASCII(@nDrive)
      WHERE Drive IS NULL

      SET @nDrive = @nDrive + 1  
   END  

   -- Show the expected output  
   SELECT UPPER(DRIVE) + ':' AS DriveLetter,
          Drive,  
          SUM(CASE WHEN Info LIKE 'Total # of bytes             : %' 
            THEN CAST(REPLACE(SUBSTRING(Info, 32, 48), master.dbo.fnc_GetCharASCII(13), '') AS BIGINT) 
            ELSE CAST(0 AS BIGINT) END)/ 1024/ 1024/ 1024 AS TotalGB,
          SUM(CASE WHEN Info LIKE 'Total # of free bytes        : %' 
            THEN CAST(REPLACE(SUBSTRING(Info, 32, 48), master.dbo.fnc_GetCharASCII(13), '') AS BIGINT) 
            ELSE CAST(0 AS BIGINT) END)/ 1024/ 1024/ 1024 AS FreeGB,
          SUM(CASE WHEN Info LIKE 'Total # of avail free bytes  : %' 
            THEN CAST(REPLACE(SUBSTRING(Info, 32, 48), master.dbo.fnc_GetCharASCII(13), '') AS BIGINT) 
            ELSE CAST(0 AS BIGINT) END)/ 1024/ 1024/ 1024 AS AvailFreeGB
   INTO   #dspace  
   FROM  (  
      SELECT Drive,  
             Info  
      FROM   @Drives  
      WHERE  Info LIKE 'Total # of %'  
      ) AS d  
   GROUP BY Drive  
   ORDER BY Drive  
   -- End Get total disk size and free size

   CREATE TABLE #tblDspace
   (
      DriveLetter NVARCHAR(2),
      TotalGB     BIGINT,
      FreeGB      BIGINT,
      [% Free]    NVARCHAR(20)
   )

   SET @SQL = 'INSERT INTO #tblDspace
               SELECT DriveLetter, TotalGB, FreeGB,
                  CEILING(CAST(REPLACE(FreeGB, '' GB'', '''') AS bigint) 
                   / CAST(REPLACE(TotalGB, '' GB'', '''') AS real) * 100) AS [% Free]
               FROM #dspace WHERE Drive IN (N''' + REPLACE(@cDriveLetterList,',',''',''') + ''')'
   EXEC (@SQL)
   IF @@ROWCOUNT = 0
   BEGIN
      RAISERROR ('No disk drive found. Please specify valid Drive Letters', 16, 1) WITH SETERROR    -- SQL2012
      --RAISERROR 74321 'No disk drive found. Please specify valid Drive Letters'
      RETURN
   END

   DROP TABLE #dspace

--select * from #tblDspace

   IF EXISTS ( SELECT 1 FROM #tblDspace WHERE FreeGB <= @nCriticalMB/1024 OR [% Free] <= @nCriticalPct )   --KHLim03
   BEGIN
      SET @cBody = @cBody + N'<table border="1" cellspacing="0" cellpadding="5">' +
          N'<tr bgcolor=silver><th>Drive<br>Letter</th>' +
          N'<th>TotalGB</th><th>FreeGB</th><th>% Free</th></tr>' +  
          CAST ( ( SELECT 'td/@align' = 'center',
                          td = ISNULL(CAST(DriveLetter AS NVARCHAR(2)),''), '',
                          td = ISNULL(CAST(TotalGB AS NVARCHAR(99)),''), '',
                          'td/@bgcolor' = CASE WHEN FreeGB <= @nCriticalMB/1024 THEN 'red' END,
                          td = ISNULL(CAST(FreeGB AS NVARCHAR(99)),''), '',
                          'td/@bgcolor' = CASE WHEN [% Free] <= @nCriticalPct THEN 'red' END,
                          td = ISNULL(CAST([% Free] AS NVARCHAR(20)) + ' %','')  --KHLim03
                   FROM #tblDspace
              FOR XML PATH('tr'), TYPE
          ) AS NVARCHAR(MAX) ) + N'</table>' ;

            INSERT INTO CNDTSITF.dbo.DBMailQueue ( mail_type, recipients, copy_recipients, subject, body, body_format, importance, AddSource )
            VALUES ( 'MAIL', @cListTo  , @cListCc  , @cSubject    , @cBody, 'HTML', 'HIGH', 'isp_GetDDSize' )

      IF EXISTS ( SELECT 1 FROM #tblDspace WHERE FreeGB <= @nCriticalMB/5024 OR [% Free] <= @nCriticalPct/5 )   --KHLim04
      BEGIN
         SET @cBody = @cSubject+' <='+CAST(@nCriticalPct/5 AS NVARCHAR(20))+'% free space only!'

         IF @cMobile1 <> ''
            INSERT INTO CNDTSITF.dbo.DBMailQueue ( mail_type, recipients, copy_recipients, subject, body, body_format, AddSource )
            VALUES ( 'SMS', 'sms@lifung.com.hk', '', 'R'+@cMobile1, @cBody, 'TEXT', 'isp_GetDDSize' )
         IF @cMobile2 <> ''
            INSERT INTO CNDTSITF.dbo.DBMailQueue ( mail_type, recipients, copy_recipients, subject, body, body_format, AddSource )
            VALUES ( 'SMS', 'sms@lifung.com.hk', '', 'R'+@cMobile2, @cBody, 'TEXT', 'isp_GetDDSize' )
         IF @cMobile3 <> ''
            INSERT INTO CNDTSITF.dbo.DBMailQueue ( mail_type, recipients, copy_recipients, subject, body, body_format, AddSource )
            VALUES ( 'SMS', 'sms@lifung.com.hk', '', 'R'+@cMobile3, @cBody, 'TEXT', 'isp_GetDDSize' )
      END
   END

   DROP TABLE #tblDspace

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetDDSize] TO nSQL 
GO
