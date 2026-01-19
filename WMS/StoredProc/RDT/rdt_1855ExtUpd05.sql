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

    DECLARE @OrderKey NVARCHAR(20)
    DECLARE @DocType NVARCHAR(20)
    DECLARE @EcomSingleFlag NVARCHAR(1)
    DECLARE @NewDropID NVARCHAR(30)
    DECLARE @bSuccess INT
    DECLARE @PickDetailKey NVARCHAR(10) 
    DECLARE @TargetPickDetailKey NVARCHAR(10) -- For cursor
    DECLARE @nTotalLines INT
    DECLARE @nShortLines INT

    SET @nErrNo = 0
    SET @cErrMsg = ''

    -- Cluster Pick (1855) at Short Pick Confirmation (Step 6)
    IF @nFunc <> 1855 OR @nStep <> 6
    BEGIN
        GOTO Quit 
    END

    -- Only proceed if Short Pick Option is selected (Option '1')
    IF @cOption <> '1'
    BEGIN
        GOTO Quit
    END

    -- Retrieve context
    SELECT @PickDetailKey = PickDetailKey
    FROM TaskDetail WITH(NOLOCK)
    WHERE TaskDetailKey = @cTaskDetailKey

    SELECT @OrderKey = OrderKey
    FROM PickDetail WITH(NOLOCK)
    WHERE PickDetailKey = @PickDetailKey

    -- Retrieve Order info
    SELECT @DocType = DocType, @EcomSingleFlag = ECOM_SINGLE_Flag
    FROM Orders WITH(NOLOCK)
    WHERE OrderKey = @OrderKey AND StorerKey = @cStorerKey

    -- Logic only applies to DocType 'E' (B2C)
    IF @DocType = 'E'
    BEGIN
        -- CASE 1: B2C Single (S)
        IF @EcomSingleFlag = 'S'
        BEGIN
             -- Verify Status is 4 (Short/Cancelled) before updating
             IF EXISTS (SELECT 1 FROM PickDetail WITH(NOLOCK) 
                        WHERE PickDetailKey = @PickDetailKey AND Status = '4')
             BEGIN
                BEGIN TRANSACTION

                 EXEC dbo.nspg_GetKey
                      @KeyName       = 'VIRTUALDROPID',
                      @fieldlength   = 30,
                      @keystring     = @NewDropID OUTPUT,
                      @b_Success     = @bSuccess OUTPUT,
                      @n_err         = @nErrNo OUTPUT,
                      @c_errmsg      = @cErrMsg OUTPUT

                 IF @bSuccess = 1
                 BEGIN
                     UPDATE PickDetail WITH (ROWLOCK)
                     SET DropID = @NewDropID 
                     WHERE PickDetailKey = @PickDetailKey

                     IF @@ERROR <> 0
                     BEGIN
                         ROLLBACK TRANSACTION
                         GOTO Quit
                     END

                     COMMIT TRANSACTION
                 END
                 ELSE
                 BEGIN
                     ROLLBACK TRANSACTION
                     GOTO Quit
                 END
            END
        END -- IF 
        
        -- CASE 2: B2C Multi (M)
        ELSE IF @EcomSingleFlag = 'M'
        BEGIN

            -- count total lines
            SELECT @nTotalLines = COUNT(1)
            FROM PickDetail WITH(NOLOCK)
            WHERE OrderKey = @OrderKey 
            AND StorerKey = @cStorerKey

            -- count shorted lines
            SELECT @nShortLines = COUNT(1)
            FROM PickDetail WITH(NOLOCK) 
            WHERE OrderKey = @OrderKey 
            AND StorerKey = @cStorerKey 
            AND Status = '4'

            -- check if ANY other PD is Status '5' (Picked), '0' (Open), or '3' (In Process)
            IF NOT EXISTS (
                SELECT 1 
                FROM PickDetail WITH(NOLOCK)
                WHERE OrderKey = @OrderKey 
                AND StorerKey = @cStorerKey
                AND Status IN ('5', '0', '3')
            )

            BEGIN
                -- Ensure ALL items are Status '4'
                -- If there is any item that is NOT '4' (and we already know it's not 5,0,3), we do not proceed.
                IF @nTotalLines > 0 AND @nTotalLines = @nShortLines
                BEGIN
                    BEGIN TRANSACTION

                    -- Condition met: All items are shorted. Generate ONE key for the whole order.
                    EXEC dbo.nspg_GetKey
                        @KeyName       = 'VIRTUALDROPID',
                        @fieldlength   = 30,
                        @keystring     = @NewDropID OUTPUT,
                        @b_Success     = @bSuccess OUTPUT,
                        @n_err         = @nErrNo OUTPUT,
                        @c_errmsg      = @cErrMsg OUTPUT

                    IF @bSuccess = 1
                    BEGIN
                        -- Update ALL PickDetails for this order using CURSOR
                        DECLARE curPickDetails CURSOR LOCAL FAST_FORWARD FOR
                            SELECT PickDetailKey
                            FROM PickDetail WITH(NOLOCK)
                            WHERE OrderKey = @OrderKey AND StorerKey = @cStorerKey AND Status = '4'

                        OPEN curPickDetails
                        FETCH NEXT FROM curPickDetails INTO @TargetPickDetailKey

                        WHILE @@FETCH_STATUS = 0
                        BEGIN
                            UPDATE PickDetail WITH (ROWLOCK)
                            SET DropID = @NewDropID
                            WHERE PickDetailKey = @TargetPickDetailKey

                            IF @@ERROR <> 0
                            BEGIN
                                ROLLBACK TRANSACTION
                                CLOSE curPickDetails
                                DEALLOCATE curPickDetails
                                GOTO Quit
                            END

                            FETCH NEXT FROM curPickDetails INTO @TargetPickDetailKey
                        END

                        CLOSE curPickDetails
                        DEALLOCATE curPickDetails
                        COMMIT TRANSACTION
                    END
                    ELSE
                    BEGIN
                        ROLLBACK TRANSACTION
                        GOTO Quit
                    END
                END
             END
        END -- ELSE IF
    END -- IF @CDoctype = 'E'
    Quit:

END
GO
GRANT EXECUTE ON [RDT].[rdt_1855ExtUpd05] TO [NSQL]
GO