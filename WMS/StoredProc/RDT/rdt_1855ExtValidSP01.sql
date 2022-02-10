IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_1855ExtValidSP01]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_1855ExtValidSP01]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  
/************************************************************************/    
/* Store procedure: rdt_1855ExtValidSP01                                */    
/* Purpose: Validate cart id prefix value                               */    
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date       Rev  Author     Purposes                                  */    
/* 2021-08-13 1.0  James      WMS-17335. Created                        */    
/************************************************************************/    
    
CREATE PROC rdt.rdt_1855ExtValidSP01 (    
   @nMobile        INT,  
   @nFunc          INT,  
   @cLangCode      NVARCHAR( 3),  
   @nStep          INT,  
   @nInputKey      INT,  
   @cFacility      NVARCHAR( 5),  
   @cStorerKey     NVARCHAR( 15),  
   @cGroupKey      NVARCHAR( 10),  
   @cTaskDetailKey NVARCHAR( 10),  
   @cPickZone      NVARCHAR( 10),  
   @cCartId        NVARCHAR( 10),  
   @cMethod        NVARCHAR( 1),  
   @cFromLoc       NVARCHAR( 10),  
   @cCartonId      NVARCHAR( 20),  
   @cSKU           NVARCHAR( 20),  
   @nQty           INT,  
   @cOption        NVARCHAR( 1),  
   @cToLOC         NVARCHAR( 10),  
   @tExtValidate   VariableTable READONLY,  
   @nErrNo         INT           OUTPUT,  
   @cErrMsg        NVARCHAR( 20) OUTPUT  
)    
AS    
   SET NOCOUNT ON         
   SET QUOTED_IDENTIFIER OFF         
   SET ANSI_NULLS OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF     
    
   DECLARE @cPickMethod    NVARCHAR( 10)  
   DECLARE @cCartonType    NVARCHAR( 10)  
   DECLARE @cUserName      NVARCHAR( 18)  
   DECLARE @cCode          NVARCHAR( 10)  
     
   SELECT @cUserName = UserName  
   FROM rdt.RDTMOBREC WITH (NOLOCK)  
   WHERE Mobile = @nMobile  
     
   IF @nStep = 2  
   BEGIN  
      IF @nInputKey = 1  
      BEGIN  
         SELECT TOP 1 @cPickMethod = PickMethod, @cCode = CL.Code  
         FROM dbo.TaskDetail TD WITH (NOLOCK)  
         JOIN dbo.CODELKUP CL WITH (NOLOCK) ON ( TD.PickMethod = CL.Long)  
         WHERE TD.Storerkey = @cStorerKey  
         AND   TD.TaskType = 'ASTCPK'  
         AND   TD.Status = '3'  
         AND   TD.Groupkey = @cGroupKey  
         AND   TD.UserKey = @cUserName  
         AND   TD.DeviceID = @cCartID  
         AND   TD.DropID = ''  
         ORDER BY CL.Code, TD.TaskDetailKey  
  
         SELECT @cCartonType = UDF01  
         FROM dbo.CODELKUP WITH (NOLOCK)  
         WHERE LISTNAME = 'TMPICKMTD'  
         AND   Storerkey = @cStorerKey  
         AND   Long = @cPickMethod  
  
         IF CHARINDEX( LEFT( @cCartonId, 1), @cCartonType) = 0  
         BEGIN  
            SET @nErrNo = 173301              
            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --InvCartPrefix      
            GOTO Quit  
         END           
      END  
   END  
    
Quit:    
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1855ExtValidSP01 to nSQL
GO   
   