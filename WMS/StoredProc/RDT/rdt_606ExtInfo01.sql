 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = Object_Id(N'[RDT].[rdt_606ExtInfo01]') AND OBJECTPROPERTY(object_id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_606ExtInfo01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 
/******************************************************************************/  
/* Store procedure: rdt_606ExtInfo01                                          */  
/* Copyright      : LF Logistics                                              */  
/*                                                                            */  
/* Purpose: Display urgent stock                                              */  
/*                                                                            */  
/* Date         Author    Ver.  Purposes                                      */  
/* 15-Apr-2015  Ung       1.0   SOS350413 Created                             */  
/******************************************************************************/  
  
CREATE PROCEDURE rdt.rdt_606ExtInfo01  
   @nMobile       INT,             
   @nFunc         INT,             
   @cLangCode     NVARCHAR( 3),    
   @nStep         INT,             
   @nAfterStep    INT,              
   @nInputKey     INT,             
   @cFacility     NVARCHAR( 5),     
   @cStorerKey    NVARCHAR( 15),   
   @cReceiptKey   NVARCHAR( 10),   
   @cRefNo        NVARCHAR( 20),   
   @nQTY          INT,             
   @cID           NVARCHAR( 18),   
   @cExtendedInfo NVARCHAR(20)  OUTPUT,    
   @nErrNo        INT           OUTPUT,   
   @cErrMsg       NVARCHAR( 20) OUTPUT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   IF @nFunc = 606 -- Return registration  
   BEGIN  
      IF @nAfterStep = 1 -- ASN  
      BEGIN  
         IF @cReceiptKey <> ''  
         BEGIN  
            IF EXISTS( SELECT 1 FROM Receipt WITH (NOLOCK) WHERE ReceiptKey = @cReceiptKey AND Userdefine01= 'Y')  
               SET @cExtendedInfo = N'(急貨)'  
         END  
      END  
   END  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON RDT.rdt_606ExtInfo01 TO NSQL
GO