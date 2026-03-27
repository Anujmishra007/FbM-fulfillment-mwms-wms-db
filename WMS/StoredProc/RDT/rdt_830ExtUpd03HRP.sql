SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/*   Stored Procedure : [RDT].[rdt_830ExtUpd03HRP]                      */
/*   Copyright        : Maersk                                          */
/*                                                                      */
/*    Purpose:                                                          */
/*        Decode logic for PMI case                                     */
/*        Auto‑Packing logic for Non‑Dedicated Orders (HRP specific)    */
/*                                                                      */
/*   Version History:                                                   */
/*   -------------------------------------------------------------------*/
/*   Date        Author    Ver   Description                            */
/*    2025-11-15  WSE016    1.0   AutoPacking for Non-Dedicated Orders  */
/*                                                                      */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_830ExtUpd03HRP]
(
      @nMobile         INT
    , @nFunc           INT
    , @cLangCode       NVARCHAR(3)
    , @nStep           INT
    , @nAfterStep      INT
    , @nInputKey       INT
    , @cFacility       NVARCHAR(5)
    , @cStorerKey      NVARCHAR(15)
    , @cPickSlipNo     NVARCHAR(10)
    , @cPickZone       NVARCHAR(10)
    , @cSuggLOC        NVARCHAR(10)
    , @cLOC            NVARCHAR(10)
    , @cDropID         NVARCHAR(20)
    , @cSKU            NVARCHAR(20)
    , @cLottable01     NVARCHAR(18)
    , @cLottable02     NVARCHAR(18)
    , @cLottable03     NVARCHAR(18)
    , @dLottable04     DATETIME
    , @dLottable05     DATETIME
    , @cLottable06     NVARCHAR(30)
    , @cLottable07     NVARCHAR(30)
    , @cLottable08     NVARCHAR(30)
    , @cLottable09     NVARCHAR(30)
    , @cLottable10     NVARCHAR(30)
    , @cLottable11     NVARCHAR(30)
    , @cLottable12     NVARCHAR(30)
    , @dLottable13     DATETIME
    , @dLottable14     DATETIME
    , @dLottable15     DATETIME
    , @cUserDefine01   NVARCHAR(30)
    , @nTaskQTY        INT
    , @nQTY            INT
    , @cToLOC          NVARCHAR(10)
    , @cOption         NVARCHAR(1)
    , @nErrNo          INT OUTPUT
    , @cErrMsg         NVARCHAR(20) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET QUOTED_IDENTIFIER OFF;
    SET ANSI_NULLS OFF;

    --------------------------------------------------------------------
    -- Local variables
    --------------------------------------------------------------------
    DECLARE 
          @cOrderKey      NVARCHAR(20)
        , @nFullyPicked   INT
        , @cLoadKey       NVARCHAR(20)
        , @nTTLCNTS       INT
        , @cOrderType     NVARCHAR(20)
        , @c_StorerKey    NVARCHAR(15) = @cStorerKey
        , @c_LabelNo      NVARCHAR(20)
        , @b_success      INT
        , @n_err          INT
        , @c_errmsg       NVARCHAR(225)
        , @n_continue     INT
        , @c_Key1         NVARCHAR(30)
        , @PalletWeight   DECIMAL(10,2);

    --------------------------------------------------------------------
    -- Generate Label Number (UCC128)
    --------------------------------------------------------------------
    EXECUTE isp_GenUCCLabelNo
              @c_StorerKey,
              @c_LabelNo  OUTPUT,
              @b_success  OUTPUT,
              @n_err      OUTPUT,
              @c_errmsg   OUTPUT;

    IF @b_success = 0
        GOTO PROC_END;

    --------------------------------------------------------------------
    -- Get Order Header Info (OrderKey, LoadKey)
    --------------------------------------------------------------------
    SELECT TOP 1
          @cOrderKey = OrderKey
        , @cLoadKey  = LoadKey
    FROM PICKHEADER WITH(NOLOCK)
    WHERE PickHeaderKey = @cPickSlipNo;

    --------------------------------------------------------------------
    -- Count unique DropIDs (used as carton count)
    --------------------------------------------------------------------
    SELECT @nTTLCNTS = COUNT(DISTINCT DropID)
    FROM PICKDETAIL WITH(NOLOCK)
    WHERE OrderKey = @cOrderKey
      AND DropID <> '';

    --------------------------------------------------------------------
    -- Get Order Type
    --------------------------------------------------------------------
    SELECT TOP 1 @cOrderType = Type
    FROM ORDERS WITH(NOLOCK)
    WHERE StorerKey = @cStorerKey
      AND OrderKey = @cOrderKey;

    --------------------------------------------------------------------
    -- Check if Order is fully picked
    --------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM ORDERDETAIL WITH(NOLOCK)
        WHERE StorerKey = @cStorerKey
          AND OrderKey = @cOrderKey
        HAVING SUM(OriginalQty) = SUM(QtyPicked)
    )
        SET @nFullyPicked = 1;
    ELSE
        SET @nFullyPicked = 0;

    SET @nErrNo = 0;
    SET @cErrMsg = '';

    --------------------------------------------------------------------
    -- MAIN LOGIC: Only run for Fn 830, Step 5, fully picked ZLF orders
    --------------------------------------------------------------------
    IF @nFunc = 830
    BEGIN
        IF @nStep = 5 AND @nFullyPicked = 1 AND @cOrderType = 'ZLF'
        BEGIN

            --------------------------------------------------------------
            -- Insert PackHeader if missing
            --------------------------------------------------------------
            IF NOT EXISTS (SELECT 1 FROM PackHeader WITH(NOLOCK) WHERE OrderKey = @cOrderKey)
            BEGIN
                INSERT INTO PackHeader
                VALUES (
                      @cPickSlipNo, @cStorerKey, '', @cOrderKey, '',
                      @cLoadKey, '', '9', USER_NAME(), GETDATE(),
                      USER_NAME(), GETDATE(), NULL, @nTTLCNTS,
                      '', '', '', '', '', 0, 0, 0, 0, 0, 0, 0,
                      'STD', 0, '', '', '', 0, 0
                );
            END;

            --------------------------------------------------------------
            -- Insert PackDetail (per DropID = per carton)
            -- Replace DropID label with generated UCCLabelNo
            --------------------------------------------------------------
            IF NOT EXISTS (SELECT 1 FROM PackDetail WHERE PickSlipNo = @cPickSlipNo)
            BEGIN
                INSERT INTO PackDetail
                    SELECT 
                          @cPickSlipNo
                        , DENSE_RANK() OVER (ORDER BY DropID) AS CartonNo
                        , @c_LabelNo AS LabelNo
                        , RIGHT('0000' + CONVERT(NVARCHAR(10),
                              ROW_NUMBER() OVER (PARTITION BY DropID ORDER BY DropID)),5) AS LabelLine
                        , @cStorerKey
                        , PKD.SKU
                        , Qty
                        , USER_NAME(), GETDATE(), USER_NAME(), GETDATE()
                        , ''
                        , NULL
                        , Qty
                        , ''
                        , DropID
                        , LA.Lottable06
                        , ''
                    FROM PICKDETAIL PKD WITH(NOLOCK)
                    INNER JOIN LOTATTRIBUTE LA ON PKD.Lot = LA.Lot
                    WHERE OrderKey = @cOrderKey AND DropID <> '';
            END;

            --------------------------------------------------------------
            -- Insert PackInfo (IML PIPA Message)
            --------------------------------------------------------------
            IF NOT EXISTS (SELECT 1 FROM PackInfo WHERE PickSlipNo = @cPickSlipNo)
            BEGIN
                -- Get pallet dead load weight
                SELECT @PalletWeight = MAX(deadload)
                FROM PalletTypeMaster WITH(NOLOCK)
                WHERE StorerKey = @cStorerKey;

                -- Insert aggregated carton-level info
                INSERT INTO PackInfo
                SELECT 
                      @cPickSlipNo
                    , DENSE_RANK() OVER (ORDER BY PD.DropID)
                    , SUM((PD.Qty * SKU.STDGrossWGT) + @PalletWeight)
                    , SUM(PD.Qty * PK.CubeUOM3)
                    , SUM(PD.Qty)
                    , GETDATE(), USER_NAME()
                    , GETDATE(), USER_NAME()
                    , ''
                    , ''
                    , ''
                    , PD.DropID
                    , ''
                    , ''
                    , ''
                    , ''
                    , ''
                    , ''
                    , ''
                FROM PACKDETAIL PD WITH(NOLOCK)
                INNER JOIN SKU WITH(NOLOCK)
                    ON PD.SKU = SKU.SKU AND SKU.StorerKey = PD.StorerKey
                INNER JOIN PACK PK WITH(NOLOCK)
                    ON PK.PackKey = SKU.PackKey
                WHERE PD.StorerKey = @cStorerKey
                  AND PD.PickSlipNo = @cPickSlipNo
                  AND PD.DropID <> ''
                GROUP BY PD.DropID;
            END;

            --------------------------------------------------------------
            -- Update Wave Status to 6 (HRP requirement)
            --------------------------------------------------------------
            IF EXISTS (
                SELECT 1
                FROM WAVE WVM WITH(NOLOCK)
                INNER JOIN WAVEDETAIL WVD WITH(NOLOCK)
                    ON WVM.WaveKey = WVD.WaveKey
                WHERE WVD.OrderKey = @cOrderKey
                  AND WVM.Status = 5
            )
            BEGIN
                UPDATE WVM
                SET WVM.Status = 6
                FROM WAVE WVM
                INNER JOIN WAVEDETAIL WVD
                    ON WVM.WaveKey = WVD.WaveKey
                WHERE WVD.OrderKey = @cOrderKey
                  AND WVM.Status = 5;
            END;

            --------------------------------------------------------------
            -- Trigger PIPA message (disabled in ITFTriggerConfig)
            --------------------------------------------------------------
            EXEC dbo.ispGenTransmitLog3
                  'SOCFMLOG'
                , @cOrderKey
                , ''
                , @cStorerKey
                , ''
                , @b_success = ''
                , @n_err = ''
                , @c_errmsg = '';

            IF @b_success <> 1
            BEGIN
                SET @n_continue = 3;
                SET @n_err = 218390;
                SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), ISNULL(@n_err,0))
                                + ': Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP) (SQLSvr MESSAGE='
                                + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ')';
                GOTO PROC_END;
            END;

            --------------------------------------------------------------
            -- Insert PACK CFM LOG (PGI_OUT IML message)
            --------------------------------------------------------------
            SET @c_Key1 = 'O' + @cOrderKey;

            EXEC dbo.ispGenTransmitLog3
                  'PACKCFMLOG'
                , @cPickSlipNo
                , @c_Key1
                , @cStorerKey
                , ''
                , @b_success OUTPUT
                , @n_err OUTPUT
                , @c_errmsg OUTPUT;

            IF @b_success <> 1
            BEGIN
                SET @n_continue = 3;
                SET @n_err = 218391;
                SET @c_errmsg = 'NSQL' + CONVERT(CHAR(5), ISNULL(@n_err,0))
                                + ': Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP) (SQLSvr MESSAGE='
                                + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ')';
                GOTO PROC_END;
            END;
        END;  -- end of Step 5 / Fully Picked / ZLF
    END;  -- end of Fn 830

PROC_END:

END;
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_830ExtUpd03HRP] TO [NSQL]