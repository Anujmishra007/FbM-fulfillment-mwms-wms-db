if exists (select * from dbo.sysobjects where id = object_id(N'rdt.rdt_1153ExtDel01') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure rdt.rdt_1153ExtDel01
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1153ExtDel01                                    */
/* Purpose: Delete the palletize record when exit the module. User will */
/*          need to palletize again                                     */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2016-04-28 1.0  James      SOS#364044. Created                       */
/************************************************************************/

CREATE PROC rdt.rdt_1153ExtDel01 (
   @nMobile                   INT, 
   @nFunc                     INT, 
   @cLangCode                 NVARCHAR( 3), 
   @nStep                     INT, 
   @nInputKey                 INT, 
   @cStorerkey                NVARCHAR( 15), 
   @cToID                     NVARCHAR( 18), 
   @cJobKey                   NVARCHAR( 10), 
   @cWorkOrderKey             NVARCHAR( 10), 
   @cSKU                      NVARCHAR( 20), 
   @nQtyToComplete            INT, 
   @cPrintLabel               NVARCHAR( 10), 
   @cEndPallet                NVARCHAR( 10), 
   @dStartDate                DATETIME,      
   @cType                     NVARCHAR( 1),   
   @nErrNo                    INT           OUTPUT,  
   @cErrMsg                   NVARCHAR( 20) OUTPUT   
)
AS

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF

   
   IF @nInputKey = 0
   BEGIN
      IF @nStep = 1
      BEGIN
         DELETE FROM dbo.WorkOrder_Palletize 
         WHERE JobKey = @cJobKey
         AND   ID = @cToID
         AND   [Status] = '3'
      END
   END

   QUIT:
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1153ExtDel01 TO NSQL
GO
