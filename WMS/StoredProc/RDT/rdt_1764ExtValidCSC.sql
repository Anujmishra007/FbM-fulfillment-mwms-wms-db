    
/********************************************************************************/    
/* Store procedure: rdt_1764ExtValidCSC                                         */    
/* Purpose: Validate if pickdetail.wavekey exists                               */    
/*                                                                              */    
/* Modifications log:                                                           */    
/*                                                                              */    
/* Date         Author    Ver.    Purposes                                      */    
/* 2026-04-14   TTW017    1.0     Created                                       */    
/********************************************************************************/    
    
CREATE PROCEDURE [rdt].[rdt_1764ExtValidCSC]    
@nMobile         INT    
,@nFunc           INT    
,@cLangCode       NVARCHAR( 3)    
,@nStep           INT    
,@cTaskdetailKey  NVARCHAR( 10)    
,@cToLoc          NVARCHAR( 10)    
,@nErrNo          INT           OUTPUT    
,@cErrMsg         NVARCHAR( 20) OUTPUT    
,@nAfterStep      INT = 0    
,@cDropID         NVARCHAR( 20) = ''    
AS    
BEGIN    
SET NOCOUNT ON    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS OFF    
SET CONCAT_NULL_YIELDS_NULL OFF    
    
DECLARE @cWavekey         NVARCHAR( 20)    
      , @cUserdefine02    NVARCHAR( 40)    
    
-- TM Replen From    
IF @nFunc = 1764    
BEGIN    
  IF @nStep = 1    
  BEGIN    
     SELECT @cWavekey = Wavekey  
     FROM dbo.TaskDetail WITH (NOLOCK)    
     WHERE TaskDetailKey = @cTaskDetailKey    
    
     SELECT @cUserdefine02 = ISNULL(Userdefine02, '')  
     FROM dbo.Wave WITH (NOLOCK)    
     WHERE Wavekey = @cWavekey  
    
     IF @cUserdefine02 = ''    
     BEGIN    
        SET @nErrNo = 63951    
        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --WAVEKEY needed    
        GOTO Quit    
     END    
  END    
END    
    
    
Quit:    
    
END 
