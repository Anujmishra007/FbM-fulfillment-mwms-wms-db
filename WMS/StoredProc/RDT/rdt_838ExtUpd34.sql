SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*************************************************************************************************/
/* Stored Procedure: rdt_838ExtUpd34                                                             */
/* Copyright       : MAERSK                                                                      */
/*                                                                                               */
/* Purpose: To generate custom carton label (PACKDETAIL.LabelNo) for non-B2C orders (FCR-11613)  */
/*          For Levis UAE (LVSUAE) - 17-char label: 7-digit prefix + 10-digit running number     */
/*                                                                                               */
/* Modification Log:                                                                             */
/*                                                                                               */
/* Date         Author     Version  Description                                                  */
/* 26-Mar-2026  NYE018     1.0      FCR-11613                                                    */
/*************************************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_838ExtUpd34]
   @nMobile          INT,
   @nFunc            INT,
   @cLangCode        NVARCHAR( 3),
   @nStep            INT,
   @nInputKey        INT,
   @cFacility        NVARCHAR( 5),
   @cStorerKey       NVARCHAR( 15),
   @cPickSlipNo      NVARCHAR( 10),
   @cFromDropID      NVARCHAR( 20),
   @nCartonNo        INT,
   @cLabelNo         NVARCHAR( 20),
   @cSKU             NVARCHAR( 20),
   @nQTY             INT,
   @cUCCNo           NVARCHAR( 20),
   @cCartonType      NVARCHAR( 10),
   @cCube            NVARCHAR( 10),
   @cWeight          NVARCHAR( 10),
   @cRefNo           NVARCHAR( 20),
   @cSerialNo        NVARCHAR( 30),
   @nSerialQTY       INT,
   @cOption          NVARCHAR( 1),
   @cPackDtlRefNo    NVARCHAR( 20),
   @cPackDtlRefNo2   NVARCHAR( 20),
   @cPackDtlUPC      NVARCHAR( 30),
   @cPackDtlDropID   NVARCHAR( 20),
   @cPackData1       NVARCHAR( 30),
   @cPackData2       NVARCHAR( 30),
   @cPackData3       NVARCHAR( 30),
   @nErrNo           INT            OUTPUT,
   @cErrMsg          NVARCHAR( 20)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @cOrderKey NVARCHAR(20)
    DECLARE @cOrderType NVARCHAR(10)
    DECLARE @cPrefix NVARCHAR(7)
    DECLARE @cNewLabelNo NVARCHAR(20)
    DECLARE @cCounterKey NVARCHAR(50)
    DECLARE @bSuccess INT
    DECLARE @nExistingCount BIGINT
    DECLARE @nTranCount INT

    SET @nErrNo = 0
    SET @cErrMsg = ''

    -- Pack Function (838)
    IF @nFunc = 838
    BEGIN
        -- Execute at step 3 (ESC - pack complete) or step 8 (Enter - UCC confirm)
        IF (@nStep = 3 AND @nInputKey = 0) OR (@nStep = 8 AND @nInputKey = 1)
        BEGIN

            -- Get OrderKey from PackHeader 
            SELECT @cOrderKey = OrderKey
            FROM dbo.PackHeader WITH(NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo AND StorerKey = @cStorerKey

            IF @cOrderKey IS NULL
                GOTO Quit

            -- Get Order Type from Orders
            SELECT @cOrderType = Type
            FROM dbo.Orders WITH(NOLOCK)
            WHERE OrderKey = @cOrderKey AND StorerKey = @cStorerKey

            -- Only apply custom label logic for non-B2C orders
            IF @cOrderType <> 'B2C'
            BEGIN
                -- Get prefix from STORER.SUSR5 (Company code + Plant code, e.g. 3672992)
                SELECT @cPrefix = SUSR5
                FROM dbo.Storer WITH(NOLOCK)
                WHERE StorerKey = @cStorerKey

                -- Build counter key: PACKLBL_<STORERKEY>
                SET @cCounterKey = 'PACKLBL_' + @cStorerKey

                SET @nTranCount = @@TRANCOUNT
                BEGIN TRAN
                SAVE TRAN rdt_838ExtUpd34

                -- Get and increment counter using nspg_GetKey
                EXEC dbo.nspg_GetKey
                    @KeyName       = @cCounterKey,
                    @fieldlength   = 20,
                    @keystring     = @cNewLabelNo OUTPUT,
                    @b_Success     = @bSuccess OUTPUT,
                    @n_err         = @nErrNo OUTPUT,
                    @c_errmsg      = @cErrMsg OUTPUT

                IF @bSuccess = 1
                BEGIN
                    -- Read existing value from nCounter
                    SELECT @nExistingCount = keycount
                    FROM dbo.nCounter WITH (NOLOCK)
                    WHERE KeyName = @cCounterKey

                    -- Build label: 7-digit prefix + 10-digit zero-padded sequence
                    -- Sequence range: 0000000001 to 9999999999
                    SET @cNewLabelNo = @cPrefix + RIGHT('0000000000' + CAST(@nExistingCount AS NVARCHAR(10)), 10)

                    BEGIN TRY
                        -- Update LabelNo in PackDetail for this carton
                        UPDATE dbo.PackDetail WITH (ROWLOCK)
                        SET LabelNo = @cNewLabelNo
                        WHERE PickSlipNo = @cPickSlipNo
                        AND LabelNo = @cLabelNo
                    END TRY
                    BEGIN CATCH
                        GOTO RollBackTran
                    END CATCH

                    IF @@ERROR <> 0
                    BEGIN
                        GOTO RollBackTran
                    END

                    COMMIT TRAN rdt_838ExtUpd34

                    GOTO Commit_Tran
                END
                ELSE
                BEGIN
                    GOTO RollBackTran
                END

                RollBackTran:
                    ROLLBACK TRAN rdt_838ExtUpd34
                Commit_Tran:
                    WHILE @@TRANCOUNT > @nTranCount
                        COMMIT TRAN
                    
                GOTO Quit
            END -- IF @cOrderType <> 'B2C'
        END -- IF @nStep = 3 OR @nStep = 8
    END -- IF @nFunc = 838

    Quit:

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_838ExtUpd34] TO [NSQL]
GO
