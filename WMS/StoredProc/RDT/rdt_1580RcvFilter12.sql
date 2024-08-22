if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdt_1580RcvFilter11]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_1580RcvFilter11]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Store procedure: rdt_1580RcvFilter12                                 */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: Defy                                                        */
/*                                                                      */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2024-08-21   1.0  JHU151     FCR-550. Created                        */  
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1580RcvFilter12]
    @nMobile     INT              
   ,@nFunc       INT              
   ,@cLangCode   NVARCHAR(  3)   
   ,@cReceiptKey NVARCHAR( 10)   
   ,@cPOKey      NVARCHAR( 10)   
   ,@cToLOC      NVARCHAR( 10)   
   ,@cToID       NVARCHAR( 18)   
   ,@cSKU        NVARCHAR( 20)   
   ,@cUCC        NVARCHAR( 20)   
   ,@nQTY        INT             
   ,@cLottable01 NVARCHAR( 18)   
   ,@cLottable02 NVARCHAR( 18)   
   ,@cLottable03 NVARCHAR( 18)   
   ,@dLottable04 DATETIME         
   ,@cCustomSQL  NVARCHAR( MAX) OUTPUT 
   ,@nErrNo      INT            OUTPUT 
   ,@cErrMsg     NVARCHAR( 20)  OUTPUT 
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @cSerialNo NVARCHAR(40)
   
   
   SELECT @cSerialNo = V_Max
   FROM rdt.rdtMobRec WITH (NOLOCK)
   WHERE Mobile = @nMobile

   SET @cCustomSQL = @cCustomSQL + 
      '     AND UserDefine01 = ''' + @cSerialNo + ''''    

QUIT:
END -- End Procedure
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_1580RcvFilter12 TO NSQL
GO
