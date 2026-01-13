SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



/*******************************************************************************/
/* Store procedure: rdt_839ExtUpd09                                            */
/* Copyright      : Maersk                                                     */ 
/* Purpose:                                                                    */
/*                                                                             */
/* Modifications log:                                                          */
/*                                                                             */
/* Date         Author    Ver.   Purposes                                      */
/* 2026-01-08   JACKC     1.0.0  FCR-9547 Hold Loc+SKU when short              */ 
/*                                                                             */
/*******************************************************************************/

CREATE OR ALTER     PROCEDURE [RDT].[rdt_839ExtUpd09]
    @nMobile         INT                   
   ,@nFunc           INT                    
   ,@cLangCode       NVARCHAR( 3)           
   ,@nStep           INT                    
   ,@nInputKey       INT                    
   ,@cFacility       NVARCHAR( 5)           
   ,@cStorerKey      NVARCHAR( 15)          
   ,@cPickSlipNo     NVARCHAR( 10)          
   ,@cPickZone       NVARCHAR( 10)          
   ,@cDropID         NVARCHAR( 20)          
   ,@cLOC            NVARCHAR( 10)          
   ,@cSKU            NVARCHAR( 20)          
   ,@nQTY            INT                    
   ,@cOption         NVARCHAR( 1)           
   ,@cLottableCode   NVARCHAR( 30)          
   ,@cLottable01     NVARCHAR( 18)          
   ,@cLottable02     NVARCHAR( 18)          
   ,@cLottable03     NVARCHAR( 18)          
   ,@dLottable04     DATETIME               
   ,@dLottable05     DATETIME               
   ,@cLottable06     NVARCHAR( 30)          
   ,@cLottable07     NVARCHAR( 30)          
   ,@cLottable08     NVARCHAR( 30)          
   ,@cLottable09     NVARCHAR( 30)          
   ,@cLottable10     NVARCHAR( 30)          
   ,@cLottable11     NVARCHAR( 30)          
   ,@cLottable12     NVARCHAR( 30)          
   ,@dLottable13     DATETIME               
   ,@dLottable14     DATETIME               
   ,@dLottable15     DATETIME
   ,@cPackData1      NVARCHAR( 30)
   ,@cPackData2      NVARCHAR( 30)
   ,@cPackData3      NVARCHAR( 30)  
   ,@nErrNo          INT           OUTPUT   
   ,@cErrMsg         NVARCHAR(250) OUTPUT   
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nDebugFlag  INT = 0

   DECLARE @bSuccess    INT   
   DECLARE @nExists     INT
   DECLARE @cShort      NVARCHAR(20)
   DECLARE @nScn        INT
   
   DECLARE
      @cAreaKey          NVARCHAR(10),
      @cCCKey            NVARCHAR(10),
      @cTaskDetailKeyCC  NVARCHAR(10)
      
   SET @nErrNo          = 0
   SET @cErrMSG         = ''

   IF @nFunc = 839
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF @nStep = 5
         BEGIN
            IF @nInputKey = 1 AND @cOption = '1' -- short
            BEGIN
               BEGIN TRY
                  EXEC dbo.nspInventoryHoldWrapper    
                     @c_lot = ''   
                     ,@c_Loc = @cLoc
                     ,@c_ID  = ''    
                     ,@c_StorerKey    = @cStorerKey    
                     ,@c_SKU          = ''    
                     ,@c_Lottable01   = ''    
                     ,@c_Lottable02   = ''    
                     ,@c_Lottable03   = ''    
                     ,@dt_Lottable04  = NULL    
                     ,@dt_Lottable05  = NULL    
                     ,@c_Lottable06   = ''    
                     ,@c_Lottable07   = ''    
                     ,@c_Lottable08   = ''    
                     ,@c_Lottable09   = ''    
                     ,@c_Lottable10   = ''    
                     ,@c_Lottable11   = ''    
                     ,@c_Lottable12   = ''    
                     ,@dt_Lottable13  = NULL    
                     ,@dt_Lottable14  = NULL    
                     ,@dt_Lottable15  = NULL    
                     ,@c_Status       = 'PickShort'   
                     ,@c_Hold         = '1'  
                     ,@b_success      = @bSuccess OUTPUT    
                     ,@n_Err          = @nErrNo OUTPUT    
                     ,@c_Errmsg       = @cErrMsg OUTPUT    
                     ,@c_Remark       = ''

                  IF @bSuccess <> '1' OR @nErrNo <> 0
                  BEGIN
                     GOTO Quit
                  END
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 256101
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Hold inv fail
                  GOTO Quit
               END CATCH

               IF NOT EXISTS (SELECT 1 FROM dbo.TaskDetail WITH (NOLOCK) WHERE TaskType = 'CC' AND FromLoc= @cLoc AND SKU = @cSKU AND Status IN ('0','3'))
               BEGIN
                  EXECUTE nspg_getkey
                     'CCKey'
                     , 10
                     , @cCCKey OUTPUT
                     , @bSuccess OUTPUT
                     , @nErrNo    --OUTPUT Commented by NLT013, it overrides the old error no, if the error was not 0, but no error happens while executing this SP, error no will be updated as 0
                     , @cErrMsg OUTPUT  

                  IF @bSuccess <> 1
                  BEGIN
                     SET @nErrNo = 256102
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Gen CCkey fail
                     GOTO Quit
                  END

                  EXECUTE dbo.nspg_getkey
                     'TaskDetailKey'
                     , 10
                     , @cTaskDetailKeyCC OUTPUT
                     , @bSuccess OUTPUT
                     , @nErrNo     
                     , @cErrMsg OUTPUT

                  IF @bSuccess <> 1
                  BEGIN
                     SET @nErrNo = 256103
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Gen TaskKey fail
                     GOTO Quit
                  END

                  SELECT @cAreaKey = AreaKey
                  FROM dbo.LOC WITH (NOLOCK)
                  JOIN dbo.AreaDetail AD WITH (NOLOCK)
                     ON LOC.PutawayZone = AD.PutawayZone
                  WHERE Facility = @cFacility
                     AND Loc = @cLoc
                  
                  BEGIN TRY
                     INSERT INTO dbo.TaskDetail
                     (TaskDetailKey,TaskType,Storerkey,Sku,Lot,UOM,UOMQty,Qty,FromLoc,LogicalFromLoc,FromID,ToLoc,LogicalToLoc
                     ,ToID,Caseid,PickMethod,Status,StatusMsg,Priority,SourcePriority,Holdkey,UserKey,UserPosition,UserKeyOverRide
                     ,StartTime,EndTime,SourceType,SourceKey,PickDetailKey,OrderKey,OrderLineNumber,ListKey,WaveKey,ReasonKey
                     ,Message01,Message02,Message03,RefTaskKey,LoadKey,AreaKey,DropID, SystemQty)
                     SELECT  @cTaskDetailKeyCC,'CC',@cStorerKey,@cSKU,'','',0,0,@cLOC,'','','',''
                     ,'','','SKU','0','','1','1','','','1',''
                     ,GetDATE(),GetDATE(),'rdt_839ExtUpd09',@cCCKey,'','','','','',''
                     ,'','','','','',@cAreaKey, '', 0
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 256104
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins task fail
                     GOTO Quit
                  END CATCH
               END -- Task not exists

            END --short
         END --st5
      END --Enter

   END
Quit:


END
GO
GRANT EXECUTE ON  [RDT].[rdt_839ExtUpd09] TO [NSQL]
GO

