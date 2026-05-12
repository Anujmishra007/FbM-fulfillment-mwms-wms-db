SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  

/************************************************************************/    
/* Store procedure: rdt_1855ExtValidSP04                                */    
/* Purpose: ToLoc must be same as suggest Loc                           */    
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date       Rev   Author      Purposes                                */    
/* 2024-12-16 1.0.0  NLT013     FCR-1755 Created                        */    
/************************************************************************/    
    
CREATE OR ALTER PROC rdt.rdt_1855ExtValidSP04 (    
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
    
   DECLARE 
      @cSuggToLOC       NVARCHAR( 10),
      @cUserName        NVARCHAR( 18),
      @cWaveKey         NVARCHAR( 10)

   SELECT 
      @cUserName  = UserName,
      @cWaveKey            = C_String1
   FROM rdt.RDTMOBREC WITH (NOLOCK)  
   WHERE Mobile = @nMobile  

   SELECT @cSuggToLOC = ToLoc      
   FROM dbo.TaskDetail WITH (NOLOCK)      
   WHERE TaskDetailKey = @cTaskDetailKey      
     
   IF @nFunc = 1855
   BEGIN
      IF @nStep = 7  
      BEGIN  
         IF @nInputKey = 1  
         BEGIN  
            IF @cPickZone <>'PICK'
            BEGIN
               IF @cToLOC <> @cSuggToLOC
               BEGIN
                  SET @nErrNo = 266401
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Location override not allowed
                  GOTO Quit
               END
            END

            DECLARE @cSuggestLoc NVARCHAR(10)

            SELECT TOP 1 @cSuggestLoc = DI.DropLoc
            FROM TaskDetail TD1 WITH(NOLOCK)
            INNER JOIN TaskDetail TD2 WITH(NOLOCK) 
               ON TD1.StorerKey = TD2.StorerKey 
               AND TD1.WaveKey = TD2.WaveKey 
               AND TD1.GroupKey = TD2.Groupkey 
               AND TD1.TaskType = TD2.TaskType
            INNER JOIN dbo.DropID DI WITH(NOLOCK) ON TD2.DropID = DI.DropID
            WHERE TD1.Storerkey = @cStorerKey
               AND TD1.TaskType = 'ASTCPK'
               AND TD1.Status = '9'
               AND TD1.DropID IS NOT NULL
               AND TD1.WaveKey = @cWaveKey
               AND TD1.GroupKey = @cGroupKey
               AND TD2.Status = '5'
               AND TD2.DeviceID = @cCartID
               AND TD2.Qty > 0
               AND TD2.TaskDetailKey = @cTaskDetailKey

            IF @@ROWCOUNT > 0
            BEGIN
               IF @cToLOC <> @cSuggestLoc
               BEGIN
                  SET @nErrNo = 266402
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Location override not allowed
                  GOTO Quit
               END
            END
         END  
      END  
   END

Quit:
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1855ExtValidSP04 to nSQL
GO