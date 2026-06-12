SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Store procedure: rdt_1764DecodeSPAU                                  */  
/* Copyright      : Maersk                                              */  
/*                                                                      */  
/* Purpose: Decode ID                                                   */  
/*                                                                      */  
/* Modifications log:                                                   */  
/* Date        Rev  Author      Purposes                                */  
/* 2025-06-13  1.0  SYC067      Created                                 */  
/************************************************************************/  
  
CREATE OR ALTER PROCEDURE [RDT].[rdt_1764DecodeSPAU]
  @nMobile        INT,  
  @nFunc          INT,  
  @cLangCode      NVARCHAR( 3),  
  @nStep          INT,  
  @nInputKey      INT,  
  @cTaskdetailKey NVARCHAR( 10),  
  @cBarcode       NVARCHAR( 60),  
  @cFromID        NVARCHAR( 18)  OUTPUT,  
  @cSKU           NVARCHAR( 20)  OUTPUT,  
  @nQTY           INT            OUTPUT,  
  @cDropID        NVARCHAR( 20)  OUTPUT,  
  @nErrNo         INT            OUTPUT,  
  @cErrMsg        NVARCHAR( 20)  OUTPUT  
AS  
BEGIN  
    SET NOCOUNT ON  
    SET QUOTED_IDENTIFIER OFF  
    SET ANSI_NULLS OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  

    SET @cFromID = ''
    SET @cSKU = ''
    SET @nQTY = 0
    SET @cDropID = ''
        
    SET @nErrNo = 0  
    SET @cErrMsg = ''  
    
    IF @nStep = 3  
    BEGIN  
        IF LEFT(ISNULL(@cBarcode,''),2) = '00' AND LEN(ISNULL(@cBarcode,'')) = 20  
            SET @cFromID = RIGHT(@cBarcode,18)  
    END  
      
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1764DecodeSPAU] TO NSQL
GO