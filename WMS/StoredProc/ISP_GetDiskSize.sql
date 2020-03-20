IF EXISTS (SELECT * FROM dbo.sysobjects WHERE Id = OBJECT_ID(N'[dbo].[isp_GetDiskSize]') AND OBJECTPROPERTY(Id, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_GetDiskSize]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Stored Procedure: isp_GetDiskSize                                    */  
/* Creation Date: 4-June-2013                                           */  
/* Copyright: IDS                                                       */  
/* Written by: CHONG CHIN SIANG                                         */  
/*                                                                      */  
/* Purpose: get Disk Drive's space (to replace isp_GetDDSize)           */  
/*                                                                      */  
/*                                                                      */  
/* Called By: ALT - Low Disk Space Notification                         */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Ver  Purposes                                   */  
/* 2013-June-07 CSCHONG 1.0  Change the critical limit to less than 10  */
/*                           for send out email   (CS01)                */
/* 2015-Jul-08  KHLim   1.1  revamp & redesign format for email & SMS   */
/************************************************************************/  
  
CREATE PROC [dbo].[isp_GetDiskSize] 
(
	 @cListTo          NVARCHAR(max)  
   ,@cListCc          NVARCHAR(max)  
	,@nCriticalPct	    int           = 10	-- if the freespace(%) is less than @nCriticalPct, it will send message
   ,@cMobile1         NVARCHAR(30)  = ''
   ,@cMobile2         NVARCHAR(30)  = ''
   ,@cMobile3         NVARCHAR(30)  = ''
)
AS
BEGIN

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS ON
   SET ANSI_WARNINGS ON
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 	@HOSTNAME 	VARCHAR(20), 
				@cSubject   VARCHAR(255),
				@BGCOLOR	   VARCHAR(50),
				@REC		   VARCHAR(50),
				@FREE       VARCHAR(20),
				@TOTAL      VARCHAR(20),
				@FREE_PER   VARCHAR(20),
				@CHART      VARCHAR(2000),
				@cBody       VARCHAR(MAX),
				@cBodyTEMP   VARCHAR(MAX),
				@DRIVE      VARCHAR(100),
				@SQL        VARCHAR(MAX)

   CREATE TABLE #MOUNTVOL (COL1 VARCHAR(500) NULL)

   INSERT INTO #MOUNTVOL
   EXEC XP_CMDSHELL 'MOUNTVOL'

   DELETE #MOUNTVOL WHERE COL1 NOT LIKE '%:%'
   DELETE #MOUNTVOL WHERE COL1 LIKE '%VOLUME%'
   DELETE #MOUNTVOL WHERE COL1 IS NULL
   DELETE #MOUNTVOL WHERE COL1 NOT LIKE '%:%'
   DELETE #MOUNTVOL WHERE COL1 LIKE '%MOUNTVOL%'
   DELETE #MOUNTVOL WHERE COL1 LIKE '%RECYCLE%'

   --SELECT LTRIM(RTRIM(COL1)) FROM #MOUNTVOL

   CREATE TABLE #DRIVES
	   (
		   DRIVE VARCHAR(500) NULL,
		   INFO VARCHAR(80) NULL
	   )

   DECLARE CUR CURSOR FOR SELECT LTRIM(RTRIM(COL1)) FROM #MOUNTVOL
   OPEN CUR
   FETCH NEXT FROM CUR INTO @DRIVE
   WHILE @@FETCH_STATUS=0 
   BEGIN
	   SET	@SQL = 'EXEC XP_CMDSHELL ''FSUTIL VOLUME DISKFREE ' + @DRIVE +''''
		
		INSERT	#DRIVES
			(
				INFO
			)
		EXEC	(@SQL)

		UPDATE	#DRIVES
		SET	DRIVE = @DRIVE
		WHERE	DRIVE IS NULL
         
   FETCH NEXT FROM CUR INTO @DRIVE
   END         
   CLOSE CUR         
   DEALLOCATE CUR       

   -- SHOW THE EXPECTED OUTPUT
   SELECT		DRIVE,
		   SUM(CASE WHEN INFO LIKE 'TOTAL # OF BYTES             : %' THEN CAST(REPLACE(SUBSTRING(INFO, 32, 48), CHAR(13), '') AS BIGINT) ELSE CAST(0 AS BIGINT) END) AS TOTALSIZE,
		   SUM(CASE WHEN INFO LIKE 'TOTAL # OF FREE BYTES        : %' THEN CAST(REPLACE(SUBSTRING(INFO, 32, 48), CHAR(13), '') AS BIGINT) ELSE CAST(0 AS BIGINT) END) AS FREESPACE
   INTO #DISKSPACE FROM		(
			   SELECT	DRIVE,
				   INFO
			   FROM	#DRIVES
			   WHERE	INFO LIKE 'TOTAL # OF %'
		   ) AS D
   GROUP BY	DRIVE
   ORDER BY	DRIVE

   SET @cBody = '<HTML><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=2>
    <TR ALIGN=CENTER STYLE=''FONT-SIZE:10.0PT;FONT-FAMILY:"TAHOMA","SANS-SERIF"''>
     <TD WIDTH=30><B>HDD</B></TD>
     <TD WIDTH=150><B>Used Space | Free %</B></TD>
     <TD WIDTH=80><B>Free Size</B></TD>
     <TD WIDTH=60><B>Total</B></TD>
   </TR>'

   DECLARE RECORDS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
   SELECT CAST(DRIVE AS VARCHAR(100))                   AS 'DRIVE'
         ,CAST(FREESPACE/1024/1024/1024 AS VARCHAR(10)) AS 'FREE'
         ,CAST(TOTALSIZE/1024/1024/1024 AS VARCHAR(10)) AS 'TOTAL'
         ,CONVERT(VARCHAR(2000),'<TABLE BORDER=0 ><TR>
            <TD border="1" cellspacing="0" BGCOLOR=#000033 WIDTH='+CAST(CAST((((TOTALSIZE-FREESPACE)/1024/1024)/((TOTALSIZE/1024/1024)*1.0))*100.0*2 AS INT) AS CHAR(10) )+' HEIGHT=5></TD>
            <TD border="1" cellspacing="0" BGCOLOR='+
             CASE WHEN ((FREESPACE/1024/1024)/((TOTALSIZE/1024/1024)*1.0))*100.0 < @nCriticalPct  
                     THEN 'RED'
                  ELSE  
                          'FFFFFF'
             END +' WIDTH='+CAST(CAST(((FREESPACE/1024/1024)/((TOTALSIZE/1024/1024)*1.0))*100.0*2 AS INT) AS CHAR(10) )+' HEIGHT=5></TD>
              <TD><B><FONT SIZE=1>'+CAST(CAST(((FREESPACE/1024/1024)/((TOTALSIZE/1024/1024)*1.0))*100.0 AS INT) AS CHAR(10) )+'%</FONT></B></TD></TR></TABLE>') AS 'CHART' 
          FROM #DISKSPACE 
      ORDER BY DRIVE

   OPEN RECORDS

   FETCH NEXT FROM RECORDS INTO @DRIVE, @FREE, @TOTAL, @CHART 
		
   WHILE @@FETCH_STATUS = 0

   BEGIN

	   SET @cBodyTEMP = 
		   '<TR BORDER=0 BGCOLOR="#E8E8E8" STYLE=''FONT-SIZE:9.0PT;FONT-FAMILY:"TAHOMA","SANS-SERIF";COLOR:#0F243E''>
		   <TD  ALIGN=CENTER><B>'+REPLACE(@DRIVE,'\','')+'</B></TD>
		   <TD VALIGN=MIDDLE><B>'+@CHART+'</B></TD>
		   <TD  ALIGN=CENTER>'+@FREE+' GB</TD>
		   <TD  ALIGN=CENTER>'+@TOTAL+' GB</TD>
		   </TR>'
		
		SET @cBody = @cBody +	@cBodyTEMP
		
	   FETCH NEXT FROM RECORDS INTO @DRIVE, @FREE, @TOTAL, @CHART 

   END
   CLOSE RECORDS
   DEALLOCATE RECORDS


   SET @cBody = @cBody + '</TABLE></HTML>'

   --############################Send Mail#############################

   SET @cSubject = 'Low Disk Space Notification - '+@@servername

   --SELECT CAST((FREESPACE/(TOTALSIZE*1.0))*100.0 AS INT) AS Size_Avai ,* FROM #DISKSPACE

   --SELECT @cBody

   IF EXISTS    (SELECT 1 FROM #DISKSPACE WHERE CAST((FREESPACE/(TOTALSIZE*1.0))*100.0 AS INT) < @nCriticalPct)    --(CS01)
	BEGIN
      INSERT INTO dbo.DBMailQueue 
             ( mail_type, recipients, copy_recipients, subject  , body  , body_format, importance, AddSource         )
      VALUES ( 'MAIL'   , @cListTo  , @cListCc       , @cSubject, @cBody, 'HTML'     , 'HIGH'    , 'isp_GetDiskSize' )

      IF EXISTS (SELECT 1 FROM #DISKSPACE WHERE CAST((FREESPACE/(TOTALSIZE*1.0))*100.0 AS INT) <= @nCriticalPct/5)
      BEGIN
         SET @cBody = @cSubject+' <='+CAST(@nCriticalPct/5 AS NVARCHAR(20))+'% free space only! Pls check mail for details.'

         IF @cMobile1 <> ''
            INSERT INTO dbo.DBMailQueue ( mail_type, recipients, subject, body  , body_format, AddSource         )
            VALUES ( 'SMS', 'SMS@lifung.com'         , 'R'+@cMobile1    , @cBody, 'TEXT'     , 'isp_GetDiskSize' )
         IF @cMobile2 <> ''
            INSERT INTO dbo.DBMailQueue ( mail_type, recipients, subject, body  , body_format, AddSource         )
            VALUES ( 'SMS', 'SMS@lifung.com'         , 'R'+@cMobile2    , @cBody, 'TEXT'     , 'isp_GetDiskSize' )
         IF @cMobile3 <> ''
            INSERT INTO dbo.DBMailQueue ( mail_type, recipients, subject, body  , body_format, AddSource         )
            VALUES ( 'SMS', 'SMS@lifung.com'         , 'R'+@cMobile3    , @cBody, 'TEXT'     , 'isp_GetDiskSize' )
      END
   END	

   DROP TABLE #MOUNTVOL
   DROP TABLE #DRIVES
   DROP TABLE #DISKSPACE

END