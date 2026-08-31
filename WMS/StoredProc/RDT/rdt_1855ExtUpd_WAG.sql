
/*************************************************************************************/
/* Store procedure: rdt_1855ExtUpd_WAG                                                 */
/* Copyright      : MAERSK                                                           */
/*                                                                                   */
/* Purpose: Extended Update Logic                                             */
/*                                                                                   */
/* Modifications log:                                                                */
/*                                                                                   */
/* Date         Ver.    Author  Purposes                                             */
/* 2024-11-09   1.0.0   NLT013  FCR-1755 Created                                     */
/* 2024-12-26   1.0.1   JCH507  FCR-1755 Wrong position at st5 when short            */
/* 2025-01-15   1.0.2   NLT013  FCR-1755 Remove duplicate scanned tote               */
/* 2025-02-12   1.0.3   NLT013  FCR-1755 Wrong position issue                        */
/* 2025-03-18   1.1.0   NLT013  UWP-31257 Fix issue, the root cause is that          */
/*                              PickDetail.TaskDetailKey <> TaskDetail.TaskDetailKey */
/* 2025-06-06   1.1.1   TAK047  INC8188873 Remove TD.FromLoc = PD.LOC join (CLVN01)  */
/* 2026-05-14   1.1.2   JRA432  Copied rdt_1855ExtUpd03 - amend for WAG              */
/*************************************************************************************/
CREATE OR ALTER   PROCEDURE [RDT].[rdt_1855ExtUpd_WAG]
   @nMobile        INT,
   @nFunc          INT,
   @cLangCode      NVARCHAR( 3),
   @nStep          INT,
   @nInputKey      INT,
   @cFacility      NVARCHAR( 5),
   @cStorerKey     NVARCHAR( 15),
   @cGroupKey      NVARCHAR( 10),
   @cTaskDetailKey NVARCHAR( 10),
   @cCartId        NVARCHAR( 10),
   @cFromLoc       NVARCHAR( 10),
   @cCartonId      NVARCHAR( 20),
   @cSKU           NVARCHAR( 20),
   @nQty           INT,
   @cOption        NVARCHAR( 1),
   @tExtUpdate     VariableTable READONLY,
   @nErrNo         INT           OUTPUT,
   @cErrMsg        NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nRowCount                 INT,
      @cPickZone                 NVARCHAR( 10),
      @cPickConfirmStatus        NVARCHAR( 1),
      @cDropID                   NVARCHAR( 20),
      @cUserName                 NVARCHAR( 18),
      @nScannedToteQty           INT,
      @cMethod                   NVARCHAR( 5),
      @cCartonType               NVARCHAR( 10),
      @cPosition                 NVARCHAR( 10)

   SET @nErrNo = 0

   SELECT
      @cUserName                    = UserName,
      @cPickZone                    = V_String24,
      @cMethod                      = V_String25
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile

   -- Get storer config  
   SET @cPickConfirmStatus = rdt.RDTGetConfig( @nFunc, 'PickConfirmStatus', @cStorerKey)  
   IF @cPickConfirmStatus = '0'  
      SET @cPickConfirmStatus = '5'  

   IF @nFunc = 1855
   BEGIN

      -----------------------------------------------------------------------
      -- STEP 4: Tote position assignment during pick
      -----------------------------------------------------------------------
      IF @nStep = 4
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cPickZone <> 'PICK'
            BEGIN
               -- Get the DropID (scanned tote) for the current task
               SELECT @cDropID = DropID
               FROM dbo.TaskDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND TaskDetailKey = @cTaskDetailKey

               -- Check if another task with the same DropID already has a position
               SELECT TOP 1 @cPosition = StatusMsg
               FROM dbo.TaskDetail WITH(NOLOCK)
               WHERE StorerKey = @cStorerKey
                  AND DropID = @cDropID
                  AND StatusMsg <> ''
                  AND TaskDetailKey <> @cTaskDetailKey

               SELECT @nRowCount = @@ROWCOUNT 

               IF @nRowCount > 0
               BEGIN
                  -- Reuse the existing position
                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET StatusMsg = @cPosition
                  WHERE StorerKey = @cStorerKey
                     AND TaskDetailKey = @cTaskDetailKey
               END
               ELSE 
               BEGIN
                  -- Calculate new position based on scanned tote count
                  SELECT @nScannedToteQty = COUNT(DISTINCT DropID)
                  FROM dbo.TaskDetail WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND GroupKey = @cGroupKey
                     AND Status = '5'
                     AND TaskType = 'ASTCPK'
                     AND DeviceID = @cCartId
                     AND UserKey = @cUserName

                  SELECT @cCartonType = UDF01
                  FROM dbo.CODELKUP WITH (NOLOCK)
                  WHERE LISTNAME = 'TMPICKMTD'
                     AND Code = @cMethod
                     AND Storerkey = @cStorerKey

                  UPDATE dbo.TaskDetail WITH (ROWLOCK)
                  SET StatusMsg = ISNULL(TRY_CAST(@nScannedToteQty AS NVARCHAR(5)), '0') + '-' + ISNULL(@cCartonType, '')
                  WHERE StorerKey = @cStorerKey
                     AND TaskDetailKey = @cTaskDetailKey
               END
            END
         END
      END --step 4

      -----------------------------------------------------------------------
      -- STEP 6: Tote position assignment (short pick / option handling)
      -----------------------------------------------------------------------
      ELSE IF @nStep = 6
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cPickZone <> 'PICK'
            BEGIN
               IF @cOption = '1'
               BEGIN
                  -- Get the DropID (scanned tote) for the current task
                  SELECT @cDropID = DropID
                  FROM dbo.TaskDetail WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND TaskDetailKey = @cTaskDetailKey

                  -- Check if another task with the same DropID already has a position
                  SELECT TOP 1 @cPosition = StatusMsg
                  FROM dbo.TaskDetail WITH(NOLOCK)
                  WHERE StorerKey = @cStorerKey
                     AND DropID = ISNULL(@cDropID, '-1')
                     AND StatusMsg <> ''
                     AND TaskDetailKey <> @cTaskDetailKey

                  SELECT @nRowCount = @@ROWCOUNT 

                  IF @nRowCount > 0
                  BEGIN
                     -- Reuse the existing position
                     UPDATE dbo.TaskDetail WITH (ROWLOCK)
                     SET StatusMsg = @cPosition
                     WHERE StorerKey = @cStorerKey
                        AND TaskDetailKey = @cTaskDetailKey
                  END
                  ELSE
                  BEGIN
                     -- Calculate new position based on scanned tote count
                     SELECT @nScannedToteQty = COUNT(DISTINCT DropID)
                     FROM dbo.TaskDetail WITH(NOLOCK)
                     WHERE StorerKey = @cStorerKey
                        AND GroupKey = @cGroupKey
                        AND Status = '5'
                        AND TaskType = 'ASTCPK'
                        AND DeviceID = @cCartId
                        AND UserKey = @cUserName

                     SELECT @cCartonType = UDF01
                     FROM dbo.CODELKUP WITH (NOLOCK)
                     WHERE LISTNAME = 'TMPICKMTD'
                        AND Code = @cMethod
                        AND Storerkey = @cStorerKey

                     UPDATE dbo.TaskDetail WITH (ROWLOCK)
                     SET StatusMsg = ISNULL(TRY_CAST(@nScannedToteQty AS NVARCHAR(5)), '0') + '-' + ISNULL(@cCartonType, '')
                     WHERE StorerKey = @cStorerKey
                        AND TaskDetailKey = @cTaskDetailKey
                  END
               END -- option 1
            END -- <> PICK
         END
      END --step 6

      -----------------------------------------------------------------------
      -- STEP 7: End of picking
      -- No CaseID clearing needed (no pre-cartonisation)
      -- No TransmitLog2 insert needed (no WCS integration)
      -- DropID is already assigned on TaskDetail from Screen 2
      -- Standard Fn 1855 handles PickDetail.DropID sync
      -----------------------------------------------------------------------
      ELSE IF @nStep = 7
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF ISNULL(@cPickZone, '') = 'PICK'
               GOTO Quit

            -- No additional processing required
            -- Add any custom end-of-pick logic here if needed in future

            GOTO Quit
         END
      END

   END

   Quit:
   IF @nErrNo <> 0
      SET @nErrNo = -1
END

GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
GRANT EXECUTE ON RDT.rdt_1855ExtUpd_WAG TO NSQL
GO
