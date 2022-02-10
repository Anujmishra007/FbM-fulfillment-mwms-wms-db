IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[RDT].[rdt_701ExtValidSP01]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_701ExtValidSP01]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO  
/************************************************************************/  
/* Store procedure: rdt_701ExtValidSP01                                 */  
/* Purpose: Validate Loc & User ID for rdtfnc_Clock_In_Out              */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date       Rev  Author     Purposes                                  */  
/* 2014-08-14 1.0  James     SOS#317982 Created                         */  
/************************************************************************/  
  
CREATE PROC rdt.rdt_701ExtValidSP01 (  
   @nMobile     INT,  
   @nFunc       INT,   
   @cLangCode   NVARCHAR( 3),   
   @nStep       INT,   
   @nInputKey   INT,   
   @cStorerKey  NVARCHAR( 15),   
   @cLocation   NVARCHAR( 10),
   @cUserID     NVARCHAR( 18), 
   @cClickCnt   NVARCHAR( 1), 
   @nErrNo      INT       OUTPUT,   
   @cErrMsg     CHAR( 20) OUTPUT
)  
AS  
  
SET NOCOUNT ON  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS OFF  

   IF @nFunc <> 701
      GOTO Quit

   IF @nInputKey = 1 AND @nStep = 1
   BEGIN  
      IF NOT EXISTS ( SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK) 
                      WHERE ListName = 'WATLOC'
                      AND   Code = @cLocation)
      BEGIN
         SET @nErrNo = 50401  -- Invalid LOC
         GOTO Quit
      END 
   END  

   IF @nInputKey = 1 AND @nStep = 2
   BEGIN  
      IF NOT EXISTS ( SELECT 1 FROM dbo.CODELKUP WITH (NOLOCK) 
                      WHERE ListName = 'WATUSER'
                      AND   Code = @cUserID)
      BEGIN
         SET @nErrNo = 50402  -- Invalid User
         GOTO Quit
      END 
   END  
  
QUIT:  

 
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_701ExtValidSP01 TO NSQL
GO
  
 