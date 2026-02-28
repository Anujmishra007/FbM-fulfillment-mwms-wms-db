SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_1813ExtUpd03                                    */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Created for the MICHELIN customer IDN                                */
/*                                                                      */
/* Date         Rev  Author   Purposes                                  */
/* Dec-16-2025  1.0  NYE018    FCR-9253 Merge Pallets and update the ID */
/************************************************************************/

CREATE OR ALTER PROC [rdt].[rdt_1813ExtUpd03](
    @nMobile          INT,
    @nFunc            INT,
    @cLangCode        NVARCHAR( 3),
    @nStep            INT,
    @nInputKey        INT,
    @cStorerKey       NVARCHAR( 15),
    @cFromID          NVARCHAR( 20),
    @cOption          NVARCHAR( 1),
    @cSKU             NVARCHAR( 20),
    @nQty             INT,
    @cToID            NVARCHAR( 20),
    @nErrNo           INT           OUTPUT,
    @cErrMsg          NVARCHAR( 20) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @nTranCount INT
    SET @nTranCount = @@TRANCOUNT
    DECLARE @SerialNoKey INT

    BEGIN TRAN
    SAVE TRAN rdt_1813ExtUpd03

    IF @nFunc = 1813 -- Scan to pallet
    BEGIN

        IF @nStep IN ( 5 , 7 )  -- Merge entire Pallet
        BEGIN
            IF @nInputKey = 1 -- ENTER
            BEGIN
                -- After pallet merge, update SerialNo.ID from FromID to ToID
                BEGIN TRY

                    DECLARE serial_cursor CURSOR FAST_FORWARD FOR
                    SELECT SN.SerialNoKey
                    FROM dbo.SerialNo SN WITH (NOLOCK)
                    WHERE SN.StorerKey = @cStorerKey
                    AND SN.ID = @cFromID

                    OPEN serial_cursor

                    FETCH NEXT FROM serial_cursor INTO @SerialNoKey

                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                        UPDATE dbo.SerialNo WITH (ROWLOCK)
                        SET ID = @cToID,
                            EditDate = GETDATE(),
                            EditWho = SUSER_NAME()
                        WHERE SerialNoKey = @SerialNoKey

                        FETCH NEXT FROM serial_cursor INTO @SerialNoKey
                    END

                    CLOSE serial_cursor
                    DEALLOCATE serial_cursor

                END TRY
                BEGIN CATCH
                    SET @nErrNo = 254451 -- SerialNoUpdFail
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') 
                    GOTO RBack
                END CATCH
            END
        END
    END

    GOTO Quit

    RBack:
        ROLLBACK TRANSACTION rdt_1813ExtUpd03 -- rollback incase of error
    Quit:
        WHILE @@TRANCOUNT > @nTranCount -- Commit until the level we started
        COMMIT TRAN

END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [rdt].[rdt_1813ExtUpd03] TO NSQL
GO