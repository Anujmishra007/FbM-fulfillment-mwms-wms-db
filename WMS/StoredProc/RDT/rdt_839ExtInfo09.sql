IF EXISTS (SELECT * FROM sys.objects WHERE Object_ID = OBJECT_ID(N'[RDT].[rdt_839ExtInfo09]') AND OBJECTPROPERTY(object_id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_839ExtInfo09]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/  
/* Store procedure: rdt_839ExtInfo09                                    */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2021-11-10 1.0  James      WMS-18286 Created                         */  
/************************************************************************/  
  
CREATE PROC rdt.rdt_839ExtInfo09 (  
   @nMobile      INT,           
   @nFunc        INT,           
   @cLangCode    NVARCHAR( 3),  
   @nStep        INT,       
   @nAfterStep   INT,    
   @nInputKey    INT,           
   @cFacility    NVARCHAR( 5) , 
   @cStorerKey   NVARCHAR( 15), 
   @cType        NVARCHAR( 10), 
   @cPickSlipNo  NVARCHAR( 10), 
   @cPickZone    NVARCHAR( 1),  
   @cDropID      NVARCHAR( 20), 
   @cLOC         NVARCHAR( 10), 
   @cSKU         NVARCHAR( 20), 
   @nQTY         INT,           
   @nActQty      INT,
   @nSuggQTY     INT,
   @cExtendedInfo NVARCHAR(20) OUTPUT, 
   @nErrNo       INT           OUTPUT, 
   @cErrMsg      NVARCHAR(250) OUTPUT  
)  
AS  

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cID         NVARCHAR( 18)
   DECLARE @cPickConfirmStatus NVARCHAR( 1)  
   DECLARE @ccurPD      CURSOR
   DECLARE @nPD_Qty     INT
   
   SET @cExtendedInfo = ''

   IF @nStep IN ( 3) OR @nAfterStep = 3
   BEGIN
      IF @nInputKey = 1
      BEGIN
         SET @cExtendedInfo = 'DROP ID: ' + @cDropID
      END
   END
  
QUIT:  
 
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_839ExtInfo09 TO NSQL
GO
  
 