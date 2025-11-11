
/************************************************************************/
/* Store procedure: [rdt_1812ExtUpd04]                                  */
/*                                                                      */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: JCB                                                         */
/*                                                                      */
/* Date        Author   Ver.     Purposes                               */
/* 2025-06-09  JCH507   1.0.0    FCR-3959 CREATED                       */
/* 2025-07-07  JCH507   1.0.1    FCR-3959 V1.6. Unhold loc in same bin  */
/*                                 if the whole pallet (FP) is picked   */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtUpd04]
   @nMobile         INT,          
   @nFunc           INT,          
   @cLangCode       NVARCHAR( 3), 
   @nStep           INT,          
   @nInputKey       INT,          
   @cTaskdetailKey  NVARCHAR( 10),
   @cDropID         NVARCHAR( 20),
   @nQTY            INT,          
   @cToLOC          NVARCHAR( 10),
   @nErrNo          INT OUTPUT,   
   @cErrMsg         NVARCHAR( 20) OUTPUT,
   @nAfterStep      INT      
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @nDebugFlag  INT = 0

   DECLARE  @cSQL        NVARCHAR(MAX),
            @cSQLParam   NVARCHAR(MAX)
   
   DECLARE  @nScn             INT,
            @nFromScn         INT,
            @nFromStep        INT,
            @cUserName        NVARCHAR(128),
            @cPickMethod      NVARCHAR(10),
            @cExtUpdPrintSP   NVARCHAR(20),
            @cStorerKey       NVARCHAR(15),
            @cToLocCate       NVARCHAR(10),
            @nToLocMaxPallet  INT,
            @nToLocIDCount    INT,
            --V1.0.2 start
            @cFromLoc         NVARCHAR(10),
            @cFromLocRoom     NVARCHAR(30),
            @nRowCount        INT,
            --V1.0.2 end
            @dDateTimeNow      DATETIME

   SELECT   @nScn = Scn,
            @nFromStep = V_FromStep,
            @nFromScn = V_FromSCN,
            @cStorerKey = StorerKey,
            @cUserName = UserName,
            @cPickMethod = V_String4
   FROM RDT.RDTMOBREC WITH (NOLOCK) WHERE Mobile = @nMobile

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812ExtUpd04'
   
   IF @nFunc = 1812 -- PickSKU
   BEGIN
      IF @nStep = 6 --ToLoc
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ST6 - ToLoc, Enter'

            --Unlock task if PND_OUT reach the pallet capacity
             IF EXISTS (
                  SELECT 1 FROM dbo.LOC WITH (NOLOCK) 
                  WHERE LOC = @cToLOC 
                     AND LocationCategory = 'PND_OUT'
               )--check location capacity
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'PND location, check capacity'

               SELECT @nToLocIDCount = COUNT (DISTINCT ID) 
               FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
               WHERE LOC = @cToLOC

               SELECT @nToLocMaxPallet = MaxPallet FROM dbo.LOC WITH (NOLOCK)
               WHERE LOC =@cToLOC

               IF @nToLocIDCount >= @nToLocMaxPallet
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Reach PND limition, unlock locked tasks'

                  IF EXISTS (
                     SELECT 1
                     FROM dbo.TaskDetail WITH (NOLOCK)
                     WHERE TaskType IN ('FCP', 'FCP1')
                        AND STATUS = '3'
                        AND UserKey = @cUserName
                        AND TaskDetailKey <> @cTaskdetailKey
                  )
                  BEGIN
                     BEGIN TRY
                        UPDATE dbo.TaskDetail WITH (ROWLOCK)
                        SET   
                           UserKey = '',
                           Status = '0'
                        WHERE TaskType IN ('FCP','FCP1')
                           AND UserKey = @cUserName
                           AND Status = '3'
                           AND TaskDetailKey <> @cTaskdetailKey
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 239751
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid CaseID
                        GOTO Quit
                     END CATCH
                  END --Unlock Tasks
               END
            END

            --Call ExtprintSP
            SET @cExtUpdPrintSP = rdt.RDTGetConfig( @nFunc, 'ExtUpdPrintSP', @cStorerKey)
            IF @cExtUpdPrintSP = '0'
               SET @cExtUpdPrintSP = ''

            IF @cExtUpdPrintSP <> ''
            BEGIN
               IF EXISTS( SELECT 1 FROM sys.sysobjects WHERE name = @cExtUpdPrintSP AND type = 'P')
               BEGIN
                  IF @nDebugFlag = 1
                     SELECT 'Executing ExtUpdPrintSP', @cExtUpdPrintSP AS ExtUpdPrintSP
                  SET @cSQL = 'EXEC rdt.' + RTRIM( @cExtUpdPrintSP) +
                     ' @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT '    
    
                  SET @cSQLParam =
                     '@nMobile         INT,           ' +
                     '@nFunc           INT,           ' +
                     '@cLangCode       NVARCHAR( 3),  ' +
                     '@nStep           INT,           ' +
                     '@nInputKey       INT,           ' +
                     '@cTaskdetailKey  NVARCHAR( 10), ' +
                     '@cDropID         NVARCHAR( 20), ' +
                     '@nQTY            INT,           ' +
                     '@cToLOC          NVARCHAR( 10), ' +
                     '@nErrNo          INT OUTPUT,    ' +
                     '@cErrMsg         NVARCHAR( 20) OUTPUT '    
    
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam,
                     @nMobile, @nFunc, @cLangCode, @nStep, @nInputKey, @cTaskdetailKey, @cDropID, @nQTY, @cToLOC, @nErrNo OUTPUT, @cErrMsg OUTPUT 
    
                  IF @nErrNo <> 0    
                     GOTO Quit 
               END
            END

            --V1.0.1 start
            SELECT
               @cFromLoc = TD.FromLoc,
               @cFromLocRoom = LOC.LocationRoom
            FROM dbo.TaskDetail TD WITH (NOLOCK)
            JOIN dbo.Pallet PL WITH (NOLOCK)
               ON TD.StorerKey = PL.StorerKey
               AND TD.FromID = PL.PalletKey
            JOIN dbo.LOC WITH (NOLOCK)
               ON TD.FromLoc = LOC.LOC
            WHERE TD.TaskDetailKey = @cTaskdetailKey
               AND TD.PickMethod = 'FP' --Full pallet
               AND PL.PalletType LIKE 'D%'

            SET @nRowCount = @@ROWCOUNT

            IF @nRowCount <> 0
            BEGIN
               IF ISNULL(@cFromLocRoom,'') <> ''
               BEGIN
                  IF EXISTS (
                     SELECT 1 
                     FROM dbo.InventoryHold IH WITH (NOLOCK)
                     JOIN dbo.LOC WITH(NOLOCK)
                        ON IH.LOC = LOC.LOC
                     WHERE LOC.LocationRoom = @cFromLocRoom
                        AND IH.Hold = 1
                        AND IH.Status = 'DoublePal'
                  )
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'Unhold locations in same beam', @cFromLOC AS FromLoc, @cFromLocRoom AS LocBeam

                     BEGIN TRY
                        UPDATE IH WITH (ROWLOCK)
                        SET Hold = '0'
                        FROM dbo.InventoryHold IH
                        JOIN dbo.LOC WITH(NOLOCK)
                           ON IH.LOC = LOC.LOC
                        WHERE LOC.LocationRoom = @cFromLocRoom
                           AND IH.Hold = 1
                           AND IH.Status = 'DoublePal' 
                     END TRY
                     BEGIN CATCH
                        SET @nErrNo = 239753
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid CaseID
                        GOTO Quit
                     END CATCH
                  END -- has loc hold by DoublePal
               END --FromLocRoom <> ''
            END --rowcount <> 0
            --V1.0.1 end

         END --inputkey = 1
      END--St6
      
      IF @nStep = 7 -- ExitTM, Next Task Scn
      BEGIN
         IF @nInputKey = 0
         BEGIN
            IF @nDebugFlag = 1
               SELECT 'ST7 - MsgScn, ESC'

            IF EXISTS (
               SELECT 1
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE TaskType IN ('FCP', 'FCP1')
                  AND STATUS = '3'
                  AND StorerKey = @cStorerKey
                  AND UserKey = @cUserName
            )
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'Unlock locked tasks'

               BEGIN TRY
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET   
                     UserKey = '',
                     Status = '0'
                  WHERE TaskType IN ('FCP','FCP1')
                     AND UserKey = @cUserName
                     AND StorerKey = @cStorerKey
                     AND Status = '3'
               END TRY
               BEGIN CATCH
                  SET @nErrNo = 239752
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid CaseID
                  GOTO Quit
               END CATCH
            END --Unlock Tasks
         END--inputkey = 0
      END --ST7
     IF @nStep = 99
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF (SELECT TOP 1 I_Field01 
               FROM RDT.RDTMOBREC WITH (NOLOCK) 
               WHERE Mobile = @nMobile) = 'SKIP'
            BEGIN
               SET @dDateTimeNow = GETDATE()

               INSERT INTO dbo.TaskManagerSkipTasks
               SELECT DISTINCT
                  RM.UserName,
                  TD1.TaskDetailKey,
                  TD1.TaskType,
                  TD1.Caseid,
                  TD1.Lot,
                  TD1.FromLoc,
                  TD1.ToLoc,
                  TD1.FromId,
                  TD1.ToId,
                  @dDateTimeNow
               FROM TaskDetail TD1 WITH (NOLOCK)
                  INNER JOIN TaskDetail TD2 WITH (NOLOCK)
                     ON TD2.TaskDetailKey = @cTaskdetailKey
                     AND TD2.StorerKey = @cStorerKey
                     AND TD1.OrderKey = TD2.OrderKey
                     AND TD1.GroupKey = TD2.GroupKey
                     AND TD1.AreaKey = TD2.AreaKey
                  LEFT JOIN RDT.RDTMOBREC RM WITH (NOLOCK)
                     ON RM.StorerKey = @cStorerKey
                     AND RM.Mobile = @nMobile
               WHERE TD1.StorerKey = @cStorerKey
          END
       END   
      END
   END --1812

   Quit:
END-- sp

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON [RDT].[rdt_1812ExtUpd04] TO [NSQL]
GO
