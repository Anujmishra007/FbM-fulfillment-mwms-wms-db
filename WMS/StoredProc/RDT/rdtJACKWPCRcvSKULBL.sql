IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdtJACKWPCRcvSKULBL]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdtJACKWPCRcvSKULBL]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/  
/* Store procedure: rdtJACKWPCRcvSKULBL                                 */  
/* Copyright      : LF logistics                                        */  
/*                                                                      */  
/* Purpose: Call from RDT piece receiving, SKULabelSP                   */  
/*                                                                      */  
/* Modifications log:                                                   */  
/* Date        Rev  Author      Purposes                                */  
/* 21-07-2014  1.0  James       SOS316036. Created                      */  
/* 07-11-2014  1.1  James       Remove traceinfo                        */  
/************************************************************************/  
  
CREATE PROCEDURE rdt.rdtJACKWPCRcvSKULBL  
    @nMobile            INT  
   ,@nFunc              INT  
   ,@nStep              INT  
   ,@cLangCode          NVARCHAR( 3)  
   ,@cStorerKey         NVARCHAR( 15)  
   ,@cDataWindow        NVARCHAR( 60)  
   ,@cPrinter           NVARCHAR( 10)  
   ,@cTargetDB          NVARCHAR( 20)  
   ,@cReceiptKey        NVARCHAR( 10)   
   ,@cReceiptLineNumber NVARCHAR( 5)   
   ,@nQTY               INT  
   ,@nErrNo             INT           OUTPUT   
   ,@cErrMsg            NVARCHAR( 20) OUTPUT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @cAltSKU     NVARCHAR( 20), 
           @cSKU        NVARCHAR( 20) 

   IF NOT EXISTS ( SELECT 1 FROM dbo.ReceiptDetail WITH (NOLOCK) 
                   WHERE ReceiptKey = @cReceiptKey 
                   AND   ReceiptLineNumber = @cReceiptLineNumber)
      GOTO Quit

   EXEC RDT.rdt_BuiltPrintJob  
      @nMobile,  
      @cStorerKey,  
      'SKULABEL',       -- ReportType  
      'PRINT_SKULABEL', -- PrintJobName  
      @cDataWindow,  
      @cPrinter,  
      @cTargetDB,  
      @cLangCode,  
      @nErrNo  OUTPUT,  
      @cErrMsg OUTPUT,  
      @cReceiptKey,  
      @cReceiptLineNumber, 
      @nQTY 
   
   Quit:  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtJACKWPCRcvSKULBL TO NSQL
GO