SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*************************************************************************************************/
/* Stored Procedure: rdt_1855ExtUpd05                                                            */
/* Copyright       : MAERSK                                                                      */
/*                                                                                               */
/* Purpose: To update virtual DropID for B2C Short picks (FCR-10039)                             */
/*                                                                                               */
/* Modification Log:                                                                             */
/*                                                                                               */
/* Date         Author     Version  Description                                                  */
/* 16-Jan-2026  NYE018     1.0      FCR-10039                                                    */
/*************************************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_1855ExtUpd05]
    @nMobile        INT,
    @nFunc          INT,
    @cLangCode      NVARCHAR(3),
    @nStep          INT,
    @nInputKey      INT,
    @cFacility      NVARCHAR(5),
    @cStorerKey     NVARCHAR(15),
    @cGroupKey      NVARCHAR(10),
    @cTaskDetailKey NVARCHAR(10),
    @cCartId        NVARCHAR(10),
    @cFromLoc       NVARCHAR(10),
    @cCartonId      NVARCHAR(20),
    @cSKU           NVARCHAR(20),
    @nQty           INT,
    @cOption        NVARCHAR(1),
    @tExtUpdate     VariableTable READONLY,
    @nErrNo         INT OUTPUT,
    @cErrMsg        NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF      
    SET CONCAT_NULL_YIELDS_NULL OFF    

    DECLARE @cOrderKey NVARCHAR(20)
    DECLARE @cDocType NVARCHAR(20)
    DECLARE @cEcomSingleFlag NVARCHAR(1)
    DECLARE @cNewDropID NVARCHAR(30)
    DECLARE @bSuccess INT
    DECLARE @cPickDetailKey NVARCHAR(10) 
    DECLARE @cTargetPickDetailKey NVARCHAR(10) -- For cursor
    DECLARE @nTotalLines INT
    DECLARE @nShortLines INT
    DECLARE @nExistingCount INT
    DECLARE @nSeqNum INT
    DECLARE @nTranCount INT
    DECLARE @cPickSlipNo NVARCHAR(30)

    SET @nErrNo = 0
    SET @cErrMsg = ''

    -- Cluster Pick (1855) at Short Pick Confirmation (Step 6)
    IF @nFunc = 1855 
    BEGIN
        
        IF @nStep = 6
        BEGIN
            -- Only proceed if Short Pick Option is selected (Option '1')
            IF @cOption = '1'
            BEGIN

                -- Get OrderKey via PickDetail
                SELECT TOP 1 @cOrderKey = PD.OrderKey
                FROM dbo.PickDetail PD WITH(NOLOCK)
                INNER JOIN dbo.TaskDetail TD WITH(NOLOCK)
                    ON PD.TaskDetailKey = TD.TaskDetailKey
                    AND PD.Lot = TD.Lot
                    AND PD.WaveKey = TD.WaveKey
                    AND PD.CaseID = TD.CaseID
                WHERE TD.TaskDetailKey = @cTaskDetailKey
                    AND PD.Status = '4'
                    AND PD.TaskDetailKey = @cTaskDetailKey
                    AND PD.DropID NOT LIKE 'QC-VIRTUAL%'  

                -- Retrieve Order info
                SELECT @cDocType = DocType, @cEcomSingleFlag = ECOM_SINGLE_Flag
                FROM dbo.Orders WITH(NOLOCK)
                WHERE OrderKey = @cOrderKey AND StorerKey = @cStorerKey

                -- Logic only applies to DocType 'E' (B2C)
                IF @cDocType = 'E'
                BEGIN
                    -- CASE 1: B2C Single (S)
                    IF @cEcomSingleFlag = 'S'
                    BEGIN
                        -- Verify Status is 4 (Short) before updating
                        IF EXISTS (SELECT 1 FROM dbo.PickDetail WITH(NOLOCK) 
                                    WHERE TaskDetailKey = @cTaskDetailKey AND OrderKey = @cOrderKey AND StorerKey = @cStorerKey AND Status = '4')
                        BEGIN
                            SET @nTranCount = @@TRANCOUNT
                            BEGIN TRAN  -- Begin our own transaction
                            SAVE TRAN rdt_1855ExtUpd05

                            EXEC dbo.nspg_GetKey
                                @KeyName       = 'VIRTUALDROPID',
                                @fieldlength   = 30,
                                @keystring     = @cNewDropID OUTPUT,
                                @b_Success     = @bSuccess OUTPUT,
                                @n_err         = @nErrNo OUTPUT,
                                @c_errmsg      = @cErrMsg OUTPUT

                            IF @bSuccess = 1
                            BEGIN
                                -- Read existing value from nCounter
                                SELECT @nExistingCount = keycount
                                FROM dbo.nCounter WITH (NOLOCK)
                                WHERE KeyName = 'VIRTUALDROPID'

                                -- Build QC-VIRTUALxxx from counter (1..999 cycling)
                                SET @nSeqNum = CAST(((@nExistingCount - 1) % 999) + 1 AS INT)
                                SET @cNewDropID = 'QC-VIRTUAL' + RIGHT('000' + CAST(@nSeqNum AS NVARCHAR(10)), 3)

                                BEGIN TRY
                                    UPDATE dbo.PickDetail WITH (ROWLOCK)
                                    SET DropID = @cNewDropID 
                                    WHERE TaskDetailKey = @cTaskDetailKey AND  OrderKey = @cOrderKey AND StorerKey = @cStorerKey AND Status = '4'
                                END TRY
                                BEGIN CATCH
                                    GOTO RollBackTran
                                END CATCH

                                IF @@ERROR <> 0
                                BEGIN
                                    GOTO RollBackTran
                                END

                                COMMIT TRAN rdt_1855ExtUpd05

                                GOTO Commit_Tran
                            END
                            ELSE
                            BEGIN
                                GOTO RollBackTran
                            END
                        END
                    END -- IF 
                    
                    -- CASE 2: B2C Multi (M)
                    ELSE IF @cEcomSingleFlag = 'M'
                    BEGIN

                        -- count total lines
                        SELECT @nTotalLines = COUNT(1)
                        FROM dbo.PickDetail WITH(NOLOCK)
                        WHERE OrderKey = @cOrderKey 
                        AND StorerKey = @cStorerKey

                        -- count shorted lines
                        SELECT @nShortLines = COUNT(1)
                        FROM dbo.PickDetail WITH(NOLOCK) 
                        WHERE OrderKey = @cOrderKey 
                        AND StorerKey = @cStorerKey 
                        AND Status = '4'

                        -- check if ANY other PD is Status '5' (Picked), '0' (Open), or '3' (In Process)
                        IF NOT EXISTS (
                            SELECT 1 
                            FROM dbo.PickDetail WITH(NOLOCK)
                            WHERE OrderKey = @cOrderKey 
                            AND StorerKey = @cStorerKey
                            AND Status IN ('5', '0', '3')
                        )

                        BEGIN
                            -- Ensure ALL items are Status '4'
                            -- If there is any item that is NOT '4' (and we already know it's not 5,0,3), we do not proceed.
                            IF @nTotalLines > 0 AND @nTotalLines = @nShortLines
                            BEGIN
                                SET @nTranCount = @@TRANCOUNT
                                BEGIN TRAN  -- Begin our own transaction
                                SAVE TRAN rdt_1855ExtUpd05

                                -- Condition met: All items are shorted. Generate ONE key for the whole order.
                                EXEC dbo.nspg_GetKey
                                    @KeyName       = 'VIRTUALDROPID',
                                    @fieldlength   = 30,
                                    @keystring     = @cNewDropID OUTPUT,
                                    @b_Success     = @bSuccess OUTPUT,
                                    @n_err         = @nErrNo OUTPUT,
                                    @c_errmsg      = @cErrMsg OUTPUT

                                IF @bSuccess = 1
                                BEGIN
                                    -- Read existing value from nCounter
                                    SELECT @nExistingCount = keycount
                                    FROM dbo.nCounter WITH (NOLOCK)
                                    WHERE KeyName = 'VIRTUALDROPID'

                                    -- Build QC-VIRTUALxxx from counter (1..999 cycling)
                                    SET @nSeqNum = CAST(((@nExistingCount - 1) % 999) + 1 AS INT)
                                    SET @cNewDropID = 'QC-VIRTUAL' + RIGHT('000' + CAST(@nSeqNum AS NVARCHAR(10)), 3)

                                    -- Update ALL PickDetails for this order using CURSOR
                                    DECLARE curPickDetails CURSOR LOCAL FAST_FORWARD FOR
                                        SELECT PickDetailKey
                                        FROM dbo.PickDetail WITH(NOLOCK)
                                        WHERE OrderKey = @cOrderKey AND StorerKey = @cStorerKey AND Status = '4'

                                    OPEN curPickDetails
                                    FETCH NEXT FROM curPickDetails INTO @cTargetPickDetailKey

                                    WHILE @@FETCH_STATUS = 0
                                    BEGIN
                                        BEGIN TRY
                                            UPDATE dbo.PickDetail WITH (ROWLOCK)
                                            SET DropID = @cNewDropID
                                            WHERE PickDetailKey = @cTargetPickDetailKey
                                        END TRY
                                        BEGIN CATCH
                                            CLOSE curPickDetails
                                            DEALLOCATE curPickDetails
                                            GOTO RollBackTran
                                        END CATCH

                                        FETCH NEXT FROM curPickDetails INTO @cTargetPickDetailKey
                                    END

                                    CLOSE curPickDetails
                                    DEALLOCATE curPickDetails

                                    COMMIT TRAN rdt_1855ExtUpd05

                                    GOTO Commit_Tran

                                END
                                ELSE
                                BEGIN
                                    GOTO RollBackTran
                                END
                            END
                        END
                    END -- ELSE IF
                END -- IF @CDoctype = 'E'

                GOTO Commit_Tran
                
                RollBackTran:
                    ROLLBACK TRAN rdt_1855ExtUpd05 -- Only rollback change made here    
                Commit_Tran:
                    WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started    
                        COMMIT TRAN
                GOTO Quit 
            END -- IF @cOption = '1'
        END -- IF @nStep = 6

        IF @nStep = 6 OR @nStep = 4 --  step 4 or 6 (confirmation)
        BEGIN
            IF @nInputKey = 1 -- Enter
            BEGIN
                -- Only update DropID if not a short pick ( IE TaskDetail.Status = 5 and PickDetail.Status = 5)
                IF EXISTS (
                    SELECT 1 
                    FROM dbo.TaskDetail TD WITH(NOLOCK)
                    INNER JOIN dbo.PickDetail PD WITH(NOLOCK) ON TD.TaskDetailKey = PD.TaskDetailKey
                    WHERE TD.TaskDetailKey = @cTaskDetailKey 
                    AND TD.Status = '5' 
                    AND PD.Status = '5'
                )
                BEGIN
                    -- Update PACKDETAIL.DropID with PICKDETAIL.DropID during pick confirmation
                    -- Link: PACKHEADER.OrderKey = PICKDETAIL.OrderKey
                    --       PACKDETAIL.PickSlipNo = PACKHEADER.PickSlipNo
                    --       PACKDETAIL.LabelNo = PICKDETAIL.CaseID

                    DECLARE @cDropID NVARCHAR(30)
                    DECLARE @cCaseID NVARCHAR(20)

                    -- Cursor to iterate over all PickDetails for this TaskDetailKey
                    DECLARE curPickDetails CURSOR LOCAL FAST_FORWARD FOR
                        SELECT OrderKey, DropID, CaseID
                        FROM dbo.PickDetail WITH(NOLOCK)
                        WHERE TaskDetailKey = @cTaskDetailKey AND StorerKey = @cStorerKey AND Status = '5'

                    OPEN curPickDetails
                    FETCH NEXT FROM curPickDetails INTO @cOrderKey, @cDropID, @cCaseID

                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        -- Get PickSlipNo from PackHeader using OrderKey
                        SELECT @cPickSlipNo = PickSlipNo
                        FROM dbo.PackHeader WITH(NOLOCK)
                        WHERE OrderKey = @cOrderKey AND StorerKey = @cStorerKey

                        BEGIN TRY
                            UPDATE dbo.PackDetail WITH (ROWLOCK)
                            SET DropID = @cDropID
                            WHERE PickSlipNo = @cPickSlipNo AND LabelNo = @cCaseID
                        END TRY
                        BEGIN CATCH
                            CLOSE curPickDetails
                            DEALLOCATE curPickDetails
                            SET @nErrNo = 261401
                            SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')  --261401^Error updating DropID in PackDetail
                            GOTO RollBackTrans
                        END CATCH

                        FETCH NEXT FROM curPickDetails INTO @cOrderKey, @cDropID, @cCaseID
                    END

                    CLOSE curPickDetails
                    DEALLOCATE curPickDetails

                    GOTO Commit_Trans

                    RollBackTrans:
                        ROLLBACK TRAN rdt_1855ExtUpd05 -- Only rollback change made here
                    Commit_Trans:
                        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
                            COMMIT TRAN
                    GOTO Quit
                END
            END -- Enter
        END -- IF @nStep = 6 OR 4

    END -- IF @nFunc = 1855
    Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1855ExtUpd05] TO [NSQL]
GO