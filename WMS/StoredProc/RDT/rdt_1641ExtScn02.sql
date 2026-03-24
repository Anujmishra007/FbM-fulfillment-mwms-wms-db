SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1641ExtScn02                                    */
/* Copyright: Maersk WMS                                                */
/*                                                                      */
/* Purpose:   FCR-10354 for Columbia                                    */
/*                                                                      */
/* Date       Rev  Author   Purposes                                    */
/* 2026-02-11 1.0  NickT    FCR-10354. Created                          */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1641ExtScn02] (
   @nMobile          INT,           
   @nFunc            INT,           
   @cLangCode        NVARCHAR( 3),  
   @nStep            INT,           
   @nScn             INT,           
   @nInputKey        INT,           
   @cFacility        NVARCHAR( 5),  
   @cStorerKey       NVARCHAR( 15), 
   @tExtScnData      VariableTable READONLY,
   @cInField01       NVARCHAR( 60) OUTPUT,  @cOutField01 NVARCHAR( 60) OUTPUT,  @cFieldAttr01 NVARCHAR( 1) OUTPUT,  @cLottable01 NVARCHAR( 18) OUTPUT,  
   @cInField02       NVARCHAR( 60) OUTPUT,  @cOutField02 NVARCHAR( 60) OUTPUT,  @cFieldAttr02 NVARCHAR( 1) OUTPUT,  @cLottable02 NVARCHAR( 18) OUTPUT,  
   @cInField03       NVARCHAR( 60) OUTPUT,  @cOutField03 NVARCHAR( 60) OUTPUT,  @cFieldAttr03 NVARCHAR( 1) OUTPUT,  @cLottable03 NVARCHAR( 18) OUTPUT,  
   @cInField04       NVARCHAR( 60) OUTPUT,  @cOutField04 NVARCHAR( 60) OUTPUT,  @cFieldAttr04 NVARCHAR( 1) OUTPUT,  @dLottable04 DATETIME      OUTPUT,  
   @cInField05       NVARCHAR( 60) OUTPUT,  @cOutField05 NVARCHAR( 60) OUTPUT,  @cFieldAttr05 NVARCHAR( 1) OUTPUT,  @dLottable05 DATETIME      OUTPUT,  
   @cInField06       NVARCHAR( 60) OUTPUT,  @cOutField06 NVARCHAR( 60) OUTPUT,  @cFieldAttr06 NVARCHAR( 1) OUTPUT,  @cLottable06 NVARCHAR( 30) OUTPUT, 
   @cInField07       NVARCHAR( 60) OUTPUT,  @cOutField07 NVARCHAR( 60) OUTPUT,  @cFieldAttr07 NVARCHAR( 1) OUTPUT,  @cLottable07 NVARCHAR( 30) OUTPUT, 
   @cInField08       NVARCHAR( 60) OUTPUT,  @cOutField08 NVARCHAR( 60) OUTPUT,  @cFieldAttr08 NVARCHAR( 1) OUTPUT,  @cLottable08 NVARCHAR( 30) OUTPUT, 
   @cInField09       NVARCHAR( 60) OUTPUT,  @cOutField09 NVARCHAR( 60) OUTPUT,  @cFieldAttr09 NVARCHAR( 1) OUTPUT,  @cLottable09 NVARCHAR( 30) OUTPUT, 
   @cInField10       NVARCHAR( 60) OUTPUT,  @cOutField10 NVARCHAR( 60) OUTPUT,  @cFieldAttr10 NVARCHAR( 1) OUTPUT,  @cLottable10 NVARCHAR( 30) OUTPUT, 
   @cInField11       NVARCHAR( 60) OUTPUT,  @cOutField11 NVARCHAR( 60) OUTPUT,  @cFieldAttr11 NVARCHAR( 1) OUTPUT,  @cLottable11 NVARCHAR( 30) OUTPUT,
   @cInField12       NVARCHAR( 60) OUTPUT,  @cOutField12 NVARCHAR( 60) OUTPUT,  @cFieldAttr12 NVARCHAR( 1) OUTPUT,  @cLottable12 NVARCHAR( 30) OUTPUT,
   @cInField13       NVARCHAR( 60) OUTPUT,  @cOutField13 NVARCHAR( 60) OUTPUT,  @cFieldAttr13 NVARCHAR( 1) OUTPUT,  @dLottable13 DATETIME      OUTPUT,
   @cInField14       NVARCHAR( 60) OUTPUT,  @cOutField14 NVARCHAR( 60) OUTPUT,  @cFieldAttr14 NVARCHAR( 1) OUTPUT,  @dLottable14 DATETIME      OUTPUT,
   @cInField15       NVARCHAR( 60) OUTPUT,  @cOutField15 NVARCHAR( 60) OUTPUT,  @cFieldAttr15 NVARCHAR( 1) OUTPUT,  @dLottable15 DATETIME      OUTPUT,
   @nAction          INT,
   @nAfterScn        INT OUTPUT, @nAfterStep    INT OUTPUT, 
   @nErrNo           INT            OUTPUT, 
   @cErrMsg          NVARCHAR( 20)  OUTPUT,
   @cUDF01  NVARCHAR( 250) OUTPUT, @cUDF02 NVARCHAR( 250) OUTPUT, @cUDF03 NVARCHAR( 250) OUTPUT,
   @cUDF04  NVARCHAR( 250) OUTPUT, @cUDF05 NVARCHAR( 250) OUTPUT, @cUDF06 NVARCHAR( 250) OUTPUT,
   @cUDF07  NVARCHAR( 250) OUTPUT, @cUDF08 NVARCHAR( 250) OUTPUT, @cUDF09 NVARCHAR( 250) OUTPUT,
   @cUDF10  NVARCHAR( 250) OUTPUT, @cUDF11 NVARCHAR( 250) OUTPUT, @cUDF12 NVARCHAR( 250) OUTPUT,
   @cUDF13  NVARCHAR( 250) OUTPUT, @cUDF14 NVARCHAR( 250) OUTPUT, @cUDF15 NVARCHAR( 250) OUTPUT,
   @cUDF16  NVARCHAR( 250) OUTPUT, @cUDF17 NVARCHAR( 250) OUTPUT, @cUDF18 NVARCHAR( 250) OUTPUT,
   @cUDF19  NVARCHAR( 250) OUTPUT, @cUDF20 NVARCHAR( 250) OUTPUT, @cUDF21 NVARCHAR( 250) OUTPUT,
   @cUDF22  NVARCHAR( 250) OUTPUT, @cUDF23 NVARCHAR( 250) OUTPUT, @cUDF24 NVARCHAR( 250) OUTPUT,
   @cUDF25  NVARCHAR( 250) OUTPUT, @cUDF26 NVARCHAR( 250) OUTPUT, @cUDF27 NVARCHAR( 250) OUTPUT,
   @cUDF28  NVARCHAR( 250) OUTPUT, @cUDF29 NVARCHAR( 250) OUTPUT, @cUDF30 NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE
      @b_success           INT,
      @cParamLabel1        NVARCHAR( 20),
      @cParamLabel2        NVARCHAR( 20),
      @cParamLabel3        NVARCHAR( 20),
      @cParamLabel4        NVARCHAR( 20),
      @cParam1             NVARCHAR( 20),
      @cParam2             NVARCHAR( 20),
      @cParam3             NVARCHAR( 20),
      @cParam4             NVARCHAR( 20),
      @cParam5             NVARCHAR( 20),
      @cPltConsigneeKey    NVARCHAR(15),
      @cParamLabel5        NVARCHAR( 20)

   DECLARE
      @cPalletCriteria        NVARCHAR( 20),
      @cFromDropID            NVARCHAR( 20),
      @cToDropID              NVARCHAR( 20),
      @cScannedDropID         NVARCHAR( 20),
      @cUserName              NVARCHAR( 18),
      @cStatus                NVARCHAR( 10),
      @cPickDetailKey         NVARCHAR( 18),
      @cOrderKey              NVARCHAR( 10),
      @cDropLOC               NVARCHAR(10),
      @cFromLOC               NVARCHAR(10),
      @cFromID                NVARCHAR(18),
      @cMarShallLoc           NVARCHAR(10),
      @cDefaultLoc            NVARCHAR(20),
      @cPriority              NVARCHAR(1),  
      @cWavekey               NVARCHAR(10),
      @cDefaultClosePalletOption NVARCHAR( 1),
      @cUCCNo              NVARCHAR(20),
      @cPltBuildNotInsDropID     NVARCHAR( 20), -- (james01)
      @cNewTaskDetailKey      NVARCHAR(10),
      @nTotalUCCCount         INT,
      @nSuccess               INT,
      @nCurrentStep           INT,
      @nRowCount              INT,
      @cDropID             NVARCHAR(20),
      @nCurrentScn            INT
   DECLARE @cMoveQTYPick   NVARCHAR( 1),
   @nLoopIndex             INT = -1,
   @nTranCount             INT
   DECLARE @tUccNo TABLE
   (
      ID    INT IDENTITY(1,1),
      UCC   NVARCHAR(20)
   )

   SELECT 
      @nCurrentStep = Step,
      @nCurrentScn = Scn,
      @cDropID          = V_String1,
      @cDropLOC         = V_String5,
      @cPalletCriteria     = V_String11,
      @cParam1             = V_String12,
      @cParam2             = V_String13,
      @cParam3             = V_String14,
      @cParam4             = V_String15,
      @cParam5             = V_String16,
      @cPltBuildNotInsDropID     = V_String19,
      @cDefaultClosePalletOption = V_String22,
      @cDefaultLoc         = V_String29,
      @cScannedDropID      = C_String1,
      @cUserName = UserName
   FROM rdt.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 1641
   BEGIN
      -- If current Step is 0
      IF @nCurrentStep IN (0,5)
      BEGIN
         IF @nStep = 1
         BEGIN
            SET @COutField01 = ''
            SET @nAfterScn = 6825
            SET @nAfterStep = 99
            GOTO QUIT
         END
      END
      ELSE IF @nCurrentStep = 99
      BEGIN
         IF @nCurrentScn = 6825
         BEGIN
            IF @nInputKey = 1
            BEGIN
               SET @cFromID = TRIM(ISNULL(@cInField01, ''))

               IF @cFromID = ''
               BEGIN
                  SET @nErrNo = 258951
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --DropID is needed
                  GOTO Quit
               END

               SELECT TOP 1 
                  @cStatus = PD.Status,
                  @cPickDetailKey = PD.PickDetailKey,
                  @cOrderKey = PD.OrderKey
               FROM dbo.PickDetail PD WITH (NOLOCK)
               JOIN dbo.Orders O WITH (NOLOCK) ON PD.OrderKey = O.OrderKey
               WHERE PD.StorerKey = @cStorerKey 
                  AND PD.ID = @cFromID
                  AND CASE WHEN @cParam1 <> '' THEN O.ConsigneeKey ELSE '' END = @cParam1 -- If consignee criteria exist, validate consignee, otherwise skip this check
               ORDER BY PD.STATUS
               SET @nRowCount = @@ROWCOUNT

               IF @nRowCount = 0
               BEGIN
                  SET @nErrNo = 258952
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Invalid DropID
                  GOTO Quit
               END

               IF @cStatus = '0'
               BEGIN
                  SET @nErrNo = 258954
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- Picking is not completed yet
                  GOTO Quit
               END

               IF @cStatus = '9'
               BEGIN
                  SET @nErrNo = 258955
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- DropID is shipped
                  GOTO Quit
               END

               IF @cStatus <> '5'
               BEGIN
                  SET @nErrNo = 258956
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --  Invalid DropID
                  GOTO Quit
               END

               SELECT
                  @cOutField02 = LEFT(DOCINFO.Data, CHARINDEX('-',DOCINFO.Data)-1), --Vas Task Code
                  @cOutField03 = RIGHT(DOCINFO.Data, LEN(DOCINFO.Data) - CHARINDEX('-', DOCINFO.Data)) -- Vas Task Description
               FROM dbo.DocInfo WITH(NOLOCK)
               WHERE DOCINFO.Key2 = @cOrderKey
                  AND DOCINFO.StorerKey = @cStorerKey
                  AND DOCINFO.TableName = 'ORDERS'   
                  AND DocInfo.Key3 = 'Z017'
                  AND CHARINDEX('-', DOCINFO.Data) > 0

               SET @cScannedDropID = @cFromID
               SET @cOutField01 = @cFromID
               SET @nAfterStep = 99
               SET @nAfterScn = 6826
               GOTO QUIT     
            END
            IF @nInputKey = 0
            BEGIN
               -- Pallet criteria
               IF @cPalletCriteria <> ''
               BEGIN
                  -- Get pallet criteria label
                  SELECT
                     @cParamLabel1 = UDF01,
                     @cParamLabel2 = UDF02,
                     @cParamLabel3 = UDF03,
                     @cParamLabel4 = UDF04,
                     @cParamLabel5 = UDF05
                  FROM dbo.CodeLKUP WITH (NOLOCK)
                  WHERE ListName = 'RDTBuildPL'
                     AND Code = @cPalletCriteria
                     AND StorerKey = @cStorerKey

                  -- Check pallet criteria setup
                  IF @cParamLabel1 = '' AND
                     @cParamLabel2 = '' AND
                     @cParamLabel3 = '' AND
                     @cParamLabel4 = '' AND
                     @cParamLabel5 = ''
                  BEGIN
                     SET @nErrNo = 69191
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Param NotSetup
                     GOTO Quit
                  END

                  -- Enable / disable field
                  SET @cFieldAttr02 = CASE WHEN @cParamLabel1 = '' THEN 'O' ELSE '' END
                  SET @cFieldAttr04 = CASE WHEN @cParamLabel2 = '' THEN 'O' ELSE '' END
                  SET @cFieldAttr06 = CASE WHEN @cParamLabel3 = '' THEN 'O' ELSE '' END
                  SET @cFieldAttr08 = CASE WHEN @cParamLabel4 = '' THEN 'O' ELSE '' END
                  SET @cFieldAttr10 = CASE WHEN @cParamLabel5 = '' THEN 'O' ELSE '' END

                  -- Clear optional in field
                  SET @cInField02 = ''
                  SET @cInField04 = ''
                  SET @cInField06 = ''
                  SET @cInField08 = ''
                  SET @cInField10 = ''

                  -- Prepare next screen var
                  SET @cOutField01 = @cParamLabel1
                  SET @cOutField02 = ''
                  SET @cOutField03 = @cParamLabel2
                  SET @cOutField04 = ''
                  SET @cOutField05 = @cParamLabel3
                  SET @cOutField06 = ''
                  SET @cOutField07 = @cParamLabel4
                  SET @cOutField08 = ''
                  SET @cOutField09 = @cParamLabel5
                  SET @cOutField10 = ''

                  -- Go to pallet criteria screen
                  SET @nAfterScn  = 2324
                  SET @nAfterStep = 5
               END
               GOTO QUIT
            END
         END
         IF @nCurrentScn = 6826
         BEGIN 
            IF @nInputKey = 1
            BEGIN
               SET @cOutField01 = ''
               SET @nAfterScn = 2320
               SET @nAfterStep = 1
            END
            IF @nInputKey = 0
            BEGIN
               SET @cOutField01 =''
               SET @nAfterScn = 6825
               SET @nAfterStep = 99
            END
            GOTO QUIT
         END
      END
      ELSE IF @nCurrentStep = 1
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF @cScannedDropID = @cInField01
            BEGIN
               -- All UCC on this ip should be added
               INSERT INTO @tUccNo(UCC)
               SELECT CASEID 
               FROM PickDetail (NOLOCK)
               WHERE ID = @cScannedDropID
                  AND StorerKey = @cStorerKey 
               -- Check UCC build on multi pallets

               SET @nTranCount = @@TRANCOUNT
               BEGIN TRAN  -- Begin our own transaction
               SAVE TRAN rdt_1641ExtScn02 -- For rollback or commit only our own transaction

               WHILE (1=1)
               BEGIN
                  SELECT @cUCCNo = UCC,
                  @nLoopIndex = ID
                  FROM @tUccNo
                  WHERE ID > @nLoopIndex
                  ORDER BY id
                  SET @nRowCount = @@ROWCOUNT

                  IF @nRowCount = 0
                     BREAK

                  IF EXISTS (SELECT 1
                     FROM DropID D WITH (NOLOCK)
                        JOIN dbo.DropIDDetail DID WITH (NOLOCK) ON (D.DropID = DID.DropID)
                     WHERE D.DropIDType = 'B'
                        AND DID.ChildID = @cUCCNo)
                  BEGIN
                     SET @nErrNo = 69201
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --UCC# Exists
                     EXEC rdt.rdtSetFocusField @nMobile, 3
                     GOTO Step_1_Fail
                  END
                  -- Create DropID
                  IF NOT EXISTS (SELECT 1 FROM dbo.DROPID WITH (NOLOCK) WHERE DropID = @cScannedDropID)
                  BEGIN
                     IF @cPalletCriteria <> ''
                        INSERT INTO dbo.DROPID (Dropid, Droploc, DropIDType, Status, UDF01, UDF02, UDF03, UDF04, UDF05)
                        VALUES (@cScannedDropID, @cDropLOC, 'B', '0', @cParam1, @cParam2, @cParam3, @cParam4, @cParam5)
                     ELSE
                        INSERT INTO dbo.DROPID (Dropid, Droploc, DropIDType, Status)
                        VALUES (@cScannedDropID, @cDropLOC, 'B', '0')
                     IF @@ERROR <> 0
                     BEGIN
                        SET @nErrNo = 69202
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins DROPIDFail
                        GOTO Step_1_Fail
                     END
                  END

                  -- Create DropIDDetail
                  INSERT INTO dbo.DropIDDetail (Dropid, ChildID) VALUES (@cScannedDropID, @cUCCNo )
                  IF @@ERROR <> 0
                  BEGIN
                     SET @nErrNo = 69203
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Ins DPDtl Fail
                     GOTO Step_1_Fail
                  END
               END
               UPDATE PICKDETAIL SET DROPID = @cScannedDropID WHERE ID = @cScannedDropID AND StorerKey = @cStorerKey
               COMMIT TRAN rdt_1641ExtScn02

               SET @cOutField01 = ''
               SET @nAfterScn = 2323
               SET @nAfterStep = 4
               GOTO QUIT
            END
         END
         IF @nInputKey = 0
         BEGIN
            SET @cOutField01 = ''
            SET @nAfterScn = 6825
            SET @nAfterStep = 99
            GOTO QUIT
         END
         GOTO QUIT
         Step_1_Fail:
            ROLLBACK TRAN
            SET @COutField01=''
            SET @nAfterStep = 1
            SET @nAfterScn = 2320
            GOTO QUIT
      END
      ELSE IF @nCurrentStep = 5
      BEGIN
         IF @nInputKey = 1 AND @nErrNo = 0
         BEGIN
            SET @cOutField01 = ''
            SET @nAfterScn = 6825
            SET @nAfterStep = 99
            GOTO QUIT
         END
      END
      ELSE IF @nCurrentStep = 4
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF ISNULL(RTRIM(@cInField01), '') = '1'
            BEGIN
               SELECT @cMarShallLoc = M.PlaceOfLoading, @cFromLOC = PD.LOC, @cFromID = PD.ID,@cWaveKey = O.USERDEFINE09
               FROM PickDetail PD (NOLOCK) 
               LEFT JOIN ORDERS O (NOLOCK) ON PD.OrderKey = O.OrderKey AND PD.StorerKey = O.StorerKey
               LEFT JOIN MBOL M WITH(NOLOCK) ON O.MBOLKey = M.MBOLKey
               WHERE PD.ID = @cDropID AND PD.StorerKey = @cStorerKey

               -- Get new TaskDetailKeys      
               SET @nSuccess = 1
               EXECUTE dbo.nspg_getkey      
                  'TASKDETAILKEY'      
                  , 10      
                  , @cNewTaskDetailKey OUTPUT      
                  , @nSuccess          OUTPUT      
                  , @nErrNo            OUTPUT      
                  , @cErrMsg           OUTPUT      
               IF @nSuccess <> 1      
               BEGIN      
                  SET @nErrNo = 233355      
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --nspg_getkey      
                  GOTO Quit      
               END

               SET @cPriority = '9'

               IF ISNULL(@cMarShallLoc,'') <> ''
               BEGIN
                  BEGIN TRY
                     INSERT INTO TaskDetail (
                        TaskDetailKey, TaskType, Status, UserKey, FromLOC, LogicalFromLoc, FromID, ToLOC, LogicalToLoc, ToID, 
                        QTY, CaseID, AreaKey, UOMQty, PickMethod, StorerKey, SKU, LOT, ListKey, SourceType, SourceKey, WaveKey, 
                        Priority, TrafficCop)
                     VALUES (
                        @cNewTaskDetailKey, 'ASTMV', '0', '', @cFromLOC, @cFromLOC, @cDropID, @cMarShallLoc, @cMarShallLoc, @cDropID, 
                        0, '', '', 0, 'FP', @cStorerKey, '', '',  '', 'rdt_1641ExtScn02',  '', @cWaveKey, 
                        @cPriority, NULL)
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 233353
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
                     GOTO Quit
                  END CATCH
               END
               ELSE 
               BEGIN
                  SELECT @cMarShallLoc = LOC FROM LOC WITH(NOLOCK) WHERE
                  Status <> 'HOLD' AND LOC.LocationFlag = 'NONE'
                  AND PutawayZone = 'CSCPNHOLD' AND Facility = @cFacility
                  BEGIN TRY
                     INSERT INTO TaskDetail (
                        TaskDetailKey, TaskType, Status, UserKey, FromLOC, LogicalFromLoc, FromID, ToLOC, LogicalToLoc, ToID, 
                        QTY, CaseID, AreaKey, UOMQty, PickMethod, StorerKey, SKU, LOT, ListKey, SourceType, SourceKey, WaveKey, 
                        Priority, TrafficCop)
                     VALUES (
                        @cNewTaskDetailKey, 'ASTPA', '0', '', @cFromLOC, @cFromLOC, @cDropID, @cMarShallLoc, @cMarShallLoc, @cDropID, 
                        0, '', '', 0, 'FP', @cStorerKey, '', '',  '', 'rdt_1641ExtScn02',  '', @cWaveKey, 
                        @cPriority, NULL)
                  END TRY
                  BEGIN CATCH
                     SET @nErrNo = 233353
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') -- InsTaskDetFail
                     GOTO Quit
                  END CATCH
               END
            END
            SET @cOutField01 = ''
            SET @nAfterScn = 6825
            SET @nAfterStep = 99
         END
      END
      
   END

   Quit:
      UPDATE RDT.RDTMOBREC WITH (ROWLOCK) SET
         C_STRING1 = @cScannedDropID
      WHERE Mobile = @nMobile


END; 

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1641ExtScn02 TO NSQL
GO
