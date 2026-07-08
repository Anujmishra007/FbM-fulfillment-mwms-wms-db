SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt_1812ExtInfoPH                                   */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-03-11   MBI165     1.0   PHARMA                                 */
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtInfoPH] (
    @nMobile         INT
   ,@nFunc           INT
   ,@cLangCode       NVARCHAR( 3)
   ,@nStep           INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@cExtendedInfo1  NVARCHAR( 20) OUTPUT
   ,@nErrNo          INT           OUTPUT
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
   ,@nAfterStep      INT = 0
)
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    -- TM Case Pick
    IF @nFunc = 1812
    BEGIN
        IF @nAfterStep = 4   -- SKU, QTY
        BEGIN
            DECLARE @cBatch    NVARCHAR( 20)
            DECLARE @cExpiry   NVARCHAR( 10)

            -- Get task info
            SELECT  TOP 1
            @cBatch     = LA.LOTTABLE01
            ,@cExpiry   = LA.Lottable04
            FROM dbo.TaskDetail TD WITH (NOLOCK)
            INNER JOIN dbo.LOTATTRIBUTE LA WITH (NOLOCK) ON TD.Lot = LA.Lot AND TD.Sku = LA.Sku AND TD.Storerkey = LA.StorerKey
            WHERE TD.TaskDetailKey = @cTaskdetailKey

            SET @cExtendedInfo1 = 'Batch:' +  @cBatch
        END
    END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_1812ExtInfoPH] TO [NSQL]
GO
