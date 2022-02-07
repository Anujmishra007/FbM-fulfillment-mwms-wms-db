if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_842ExtInfo01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdt_842ExtInfo01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/  
/* Store procedure: rdt_842ExtInfo01                                    */  
/* Copyright      : LF                                                  */  
/*                                                                      */  
/* Purpose: LULU DTC Logic                                              */  
/*                                                                      */  
/* Modifications log:                                                   */  
/* Date        Rev  Author   Purposes                                   */  
/* 2016-06-16  1.0  ChewKP   SOS#371222 Created                         */  
/************************************************************************/  

CREATE PROC [RDT].[rdt_842ExtInfo01] (  
   @nMobile        INT,              
   @nFunc          INT,              
   @cLangCode      NVARCHAR(3),      
   @nStep          INT,              
   @cUserName      NVARCHAR( 18),     
   @cFacility      NVARCHAR( 5),      
   @cStorerKey     NVARCHAR( 15),     
   @cDropID        NVARCHAR( 20),     
   @cOutField01    NVARCHAR( 20) OUTPUT,  
   @cOutField02    NVARCHAR( 20) OUTPUT,  
   @cOutField03    NVARCHAR( 20) OUTPUT,  
   @cOutField04    NVARCHAR( 20) OUTPUT,  
   @cOutField05    NVARCHAR( 20) OUTPUT,  
   @cOutField06    NVARCHAR( 20) OUTPUT,  
   @nErrNo         INT OUTPUT,      
   @cErrMsg        NVARCHAR( 20) OUTPUT
) AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @cMDropID NVARCHAR(20)
          ,@cOrderKey NVARCHAR(10) 
          ,@nCount    INT
          
        


  
   SET @nErrNo   = 0  
   SET @cErrMsg  = ''  

   
  
  
 
   IF @nStep = 1 
   BEGIN
      
      SET @nCount = 1 
      SET @cOutField01 = '' 
      SET @cOutField02 = '' 
      SET @cOutField03 = '' 
      SET @cOutField04 = '' 
      SET @cOutField05 = '' 
      SET @cOutField06 = '' 
      
      SELECT TOP 1 @cOrderKey = OrderKey 
      FROM dbo.PickDetail PD WITH (NOLOCK)  
      WHERE PD.StorerKey = @cStorerKey 
        AND PD.DropID = @cDropID
        AND PD.Status = '5'  
        AND PD.CaseID = ''
      
      
      DECLARE C_TOTE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   
      SELECT DISTINCT DropID
      FROM dbo.PickDetail PD WITH (NOLOCK)  
      WHERE PD.StorerKey = @cStorerKey 
        AND PD.OrderKey  = @cOrderKey   
        AND PD.Status = '5'  
        AND PD.CaseID = ''
      
      
      OPEN C_TOTE  
      FETCH NEXT FROM C_TOTE INTO  @cMDropID
      WHILE (@@FETCH_STATUS <> -1)  
      BEGIN  
         IF @nCount = 1 
         BEGIN
            SET @cOutField01 = @cMDropID
         END   
         ELSE IF @nCount = 2 
         BEGIN
            SET @cOutField02 = @cMDropID
         ENd
         ELSE IF @nCount = 3
         BEGIN
            SET @cOutField03 = @cMDropID
         ENd
         ELSE IF @nCount = 4
         BEGIN
            SET @cOutField04 = @cMDropID
         ENd
         ELSE IF @nCount = 5
         BEGIN
            SET @cOutField05 = @cMDropID
         ENd
         ELSE IF @nCount = 6
         BEGIN
            SET @cOutField06 = @cMDropID
         ENd                  
         
         SET @nCount = @nCount + 1 
         
         IF @nCount > 6 
         BREAK 
         
         FETCH NEXT FROM C_TOTE INTO  @cMDropID   
      END
      CLOSE C_TOTE  
      DEALLOCATE C_TOTE  
         
      
   END
  
   GOTO QUIT       
         
      
Quit:      
        
      
END  

GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdt_842ExtInfo01 TO NSQL
GO
