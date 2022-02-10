if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdtScr2Script]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdtScr2Script]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/************************************************************************/
/* Store procedure: rdtScr2Script                                       */
/* Creation Date  :                                                     */
/* Copyright      : IDS                                                 */
/* Written By     : dhung                                               */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Rev  Author     Purposes                                */
/* 25-Jun-2015  1.1  TLTING     Performance Tune                        */
/************************************************************************/


CREATE PROCEDURE rdt.rdtScr2Script 
   @nScn INT, 
   @cLangCode NVARCHAR( 3) = N'ENG'
AS
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cScn NVARCHAR( 10)
   DECLARE @i INT
   DECLARE @ci NVARCHAR( 2)
   DECLARE @cValue NVARCHAR( 60)
   DECLARE @cSQL NVARCHAR( 1024)

   SET @cScn = CAST( @nScn AS NVARCHAR( 10))

   IF NOT EXISTS( SELECT 1 FROM rdt.RDTScn with (NOLOCK) WHERE Scn = @nScn AND Lang_Code = @cLangCode)
   BEGIN
      PRINT 'Screen ' + @cScn + ' not found'
      PRINT ''
      RETURN
   END

   PRINT '-- ' + @cScn + ' = ?? screen'
   PRINT 'DELETE rdt.RDTScn WHERE Scn = ' + @cScn + ' AND Lang_Code = ''' + @cLangCode + ''''
   PRINT 'EXECUTE rdt.rdtAddScn ' + @cScn + ', ''' + @cLangCode + ''''

   SET @i = 1
   WHILE @i < 16
   BEGIN
      SET @ci = RIGHT( '00' + CAST( @i AS NVARCHAR( 2)), 2)
      SET @cValue = NULL
      SET @cSQL = 'SELECT @cValue = Line' + @ci + 
         ' FROM rdt.RDTScn  with (NOLOCK) ' + 
         ' WHERE Scn = ' + CAST( @nScn AS NVARCHAR( 10)) + 
            ' AND Lang_Code = ''' + @cLangCode + ''''

      EXECUTE sp_executesql @cSQL, N'@cValue NVARCHAR( 60) OUTPUT', @cValue OUTPUT

      IF @cValue IS NOT NULL
         PRINT '   ,@cLine' + @ci + ' = N''' + @cValue + ''''

      SET @i = @i + 1
   END
   PRINT ''
GO
GRANT EXECUTE ON RDT.rdtScr2Script TO NSQL
GO
