/****** Object:  UserDefinedFunction [RDT].[rdtFormatDate]    Script Date: 08/22/2008 23:29:27 ******/
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdtFormatDate]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [RDT].[rdtFormatDate]
GO

/****** Object:  UserDefinedFunction [RDT].[rdtFormatDate]    Script Date: 08/22/2008 23:29:00 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: rdtFormatDate    					                     */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Format date to string, according to the dateformat of       */
/*          current sql login's language.                               */
/*          Note: it does not consider SET DATEFORMAT                   */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 2005-11-17   dhung         Created                                   */
/* 2016-11-01   ChewKP        Replace IsDate() (ChewKP01)               */
/************************************************************************/

CREATE FUNCTION [RDT].[rdtFormatDate] (
   @dDate DATETIME
) RETURNS NVARCHAR( 10) AS
BEGIN
   -- Parameter checking
   IF @dDate IS NULL OR @dDate = 0 -- when pass in '' or 0, @dDate = 0 (1900-01-01 00:00:00.000)
      GOTO Fail

   DECLARE @cDateFormat NVARCHAR( 3)
   DECLARE @cDate       NVARCHAR( 10)
   DECLARE @cDD         NVARCHAR( 2)
   DECLARE @cMM         NVARCHAR( 2)
   DECLARE @cYYYY       NVARCHAR( 4)
   DECLARE @cDelimeter  NVARCHAR( 1)

   SET @cDelimeter = '/'  -- hardcode
   SELECT 
      @cDD = RIGHT( '0' + RTRIM( DATEPART( dd, @dDate)), 2),
      @cMM = RIGHT( '0' + RTRIM( DATEPART( mm, @dDate)), 2),
      @cYYYY = DATEPART( yyyy, @dDate)
   
   -- Get the dateformat of current SQL login
   SET @cDateFormat = RDT.rdtGetDateFormat( SYSTEM_USER)
   
   -- Format the date according to the dateformats supported
   SELECT @cDate = 
      CASE @cDateFormat
         WHEN 'dmy' THEN @cDD   + @cDelimeter + @cMM   + @cDelimeter + @cYYYY
         WHEN 'mdy' THEN @cMM   + @cDelimeter + @cDD   + @cDelimeter + @cYYYY
         WHEN 'ymd' THEN @cYYYY + @cDelimeter + @cMM   + @cDelimeter + @cDD
         WHEN 'ydm' THEN @cYYYY + @cDelimeter + @cDD   + @cDelimeter + @cMM
         WHEN 'myd' THEN @cMM   + @cDelimeter + @cYYYY + @cDelimeter + @cDD
         WHEN 'dym' THEN @cDD   + @cDelimeter + @cYYYY + @cDelimeter + @cMM
      END
   GOTO Quit

Fail:
   RETURN ''
Quit:
   RETURN @cDate
END
GO

GRANT EXECUTE on [RDT].[rdtFormatDate] to nSQL
GO
