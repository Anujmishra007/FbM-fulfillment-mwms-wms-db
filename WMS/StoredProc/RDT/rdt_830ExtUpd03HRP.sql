SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/*Stored Procedure : [RDT].[rdt_830ExtUpd03HRP]                         */
/*Copyright        : Maersk                                             */
/*                                                                      */
/* Purpose:                                                             */
/* Decode logic for PMI case                                            */
/* Auto-Packing logic for Non-Dedicated Orders (HRP specific)           */
/*                                                                      */
/*Version History:                                                      */
/*----------------------------------------------------------------------*/
/*Date        Author    Ver   Description                               */
/*2025-11-15  WSE016    1.0   AutoPacking for Non-Dedicated Orders      */
/*2026-04-28  PYW009    1.1   UWP-57192 INC9280245 one carton one       */
/*                            labelno and enhancement                   */
/************************************************************************/
  
CREATE OR ALTER  PROC [RDT].[rdt_830ExtUpd03HRP]  
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
   , @nErrNo          INT          OUTPUT  
   , @cErrMsg         NVARCHAR(20) OUTPUT  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
    --------------------------------------------------------------------  
    -- Local variables  
    --------------------------------------------------------------------   
   DECLARE
     @cOrderKey      NVARCHAR(20)
   , @nFullyPicked   INT
   , @cLoadKey       NVARCHAR(20)
   , @nTTLCNTS       INT
   , @cOrderType     NVARCHAR(20)
   , @c_LabelNo      NVARCHAR(20)
   , @b_success      INT
   , @c_Key1         NVARCHAR(30)
   , @PalletWeight   DECIMAL(10,2)
   , @c_DropID_CUR   NVARCHAR(20)
   , @CartonNo       INT = 1
   , @nTranStarted   INT = 0
   , @cSavePoint     NVARCHAR(32) = 'SP_830ExtUpd03HRP';  
  
   --------------------------------------------------------------------  
   -- Get Order Header Info (OrderKey, LoadKey)  
   --------------------------------------------------------------------  
   SELECT TOP 1  
     @cOrderKey = OrderKey  
   , @cLoadKey  = LoadKey  
   FROM dbo.PICKHEADER WITH (NOLOCK)  
   WHERE PickHeaderKey = @cPickSlipNo;  
  
   --------------------------------------------------------------------  
   -- Count unique DropIDs (used as carton count)  
   -------------------------------------------------------------------- 
   SELECT @nTTLCNTS = COUNT(DISTINCT DropID)  
   FROM dbo.PICKDETAIL WITH (NOLOCK)  
   WHERE OrderKey = @cOrderKey  
   AND DropID <> '';  
   
   --------------------------------------------------------------------  
   -- Get Order Type  
   --------------------------------------------------------------------   
   SELECT TOP 1 @cOrderType = Type  
   FROM dbo.ORDERS WITH (NOLOCK)  
   WHERE StorerKey = @cStorerKey  
   AND OrderKey = @cOrderKey;  
  
   --------------------------------------------------------------------  
   -- Check if Order is fully picked  
   -------------------------------------------------------------------- 
    IF EXISTS ( SELECT 1  
                FROM dbo.ORDERDETAIL WITH (NOLOCK)  
                WHERE StorerKey = @cStorerKey  
                AND OrderKey = @cOrderKey  
                HAVING SUM(OriginalQty) = SUM(QtyPicked) )  
    BEGIN  
        SET @nFullyPicked = 1;  
    END  
    ELSE  
    BEGIN  
        SET @nFullyPicked = 0;  
    END  

    SET @nErrNo = 0;  
    SET @cErrMsg = '';
  
   --------------------------------------------------------------------
   -- MAIN LOGIC: Only run for Fn 830, Step 5, fully picked ZLF orders
   --------------------------------------------------------------------
    IF @nFunc = 830
    BEGIN
        IF @nStep = 5 AND @nFullyPicked = 1 AND @cOrderType = 'ZLF'
        BEGIN
            -- Begin transaction or create savepoint
            IF @@TRANCOUNT = 0
            BEGIN
                BEGIN TRANSACTION;
                SET @nTranStarted = 1;
            END
            ELSE
            BEGIN
                SAVE TRANSACTION @cSavePoint;
            END;

            BEGIN TRY  
            --------------------------------------------------------------  
            -- Insert PackHeader if missing   
            --------------------------------------------------------------  
            IF NOT EXISTS (SELECT 1 FROM dbo.PackHeader WITH (NOLOCK) WHERE OrderKey = @cOrderKey)  
            BEGIN  
            INSERT INTO dbo.PackHeader (  PickSlipNo, StorerKey, Route, OrderKey, OrderRefNo, LoadKey, ConsigneeKey, Status  
                                    --, AddWho, AddDate, EditWho, EditDate, ArchiveCop  
                                    , TTLCNTS, CtnTyp1, CtnTyp2, CtnTyp3, CtnTyp4, CtnTyp5  
                                    , CtnCnt1, CtnCnt2, CtnCnt3, CtnCnt4, CtnCnt5  
                                    , TotCtnWeight, TotCtnCube, CartonGroup, ManifestPrinted  
                                    , ConsoOrderKey, TaskBatchNo, ComputerName, PackStatus, EstimateTotalCtn )  
            VALUES ( @cPickSlipNo, @cStorerKey, '', @cOrderKey, '', @cLoadKey, '', '9'  
                    --, USER_NAME(), GETDATE(), USER_NAME(), GETDATE(), NULL  
                        , @nTTLCNTS, '', '', '', '', ''  
                        , 0, 0, 0, 0, 0  
                        , 0, 0, 'STD', 0  
                        , '', '', '', 0, 0 );  
            END;  

            --------------------------------------------------------------
            -- Insert PackDetail (Cursor per DropID) --INC9280245 Use cursor to use generated labelno
            --------------------------------------------------------------
            DECLARE DROP_CURSOR CURSOR LOCAL FAST_FORWARD FOR
            SELECT DISTINCT DropID
            FROM dbo.PICKDETAIL WITH (NOLOCK)
            WHERE OrderKey = @cOrderKey
            AND DropID <> ''
            AND NOT EXISTS ( SELECT 1 FROM dbo.PackDetail (NOLOCK) 
                      WHERE PickslipNo = @cPickSlipNo)
            ORDER BY DropID; 

            OPEN DROP_CURSOR;  
            FETCH NEXT FROM DROP_CURSOR INTO @c_DropID_CUR;  

            WHILE @@FETCH_STATUS = 0  
            BEGIN  
            SET @c_LabelNo = ''  
            EXEC isp_GenUCCLabelNo  
                @cStorerKey,  
                @c_LabelNo OUTPUT,  
                @b_success OUTPUT,  
                @nErrNo     OUTPUT,  
                @cErrMsg  OUTPUT;  

            IF @b_success = 1  
            BEGIN  
                INSERT INTO dbo.PackDetail (  PickSlipNo, CartonNo  
                                        , LabelNo, LabelLine, StorerKey, Sku, Qty  
                                        --, AddWho, AddDate, EditWho, EditDate  
                                        , RefNo, ArchiveCop, ExpQty, UPC  
                                        , DropId, RefNo2, LottableValue )  
                SELECT  
                    @cPickSlipNo,  
                    @CartonNo,  
                    @c_LabelNo,  
                    RIGHT('0000' + CONVERT(NVARCHAR(10),  
                    ROW_NUMBER() OVER (PARTITION BY PD.DropID ORDER BY PD.DropID)),5),  
                    @cStorerKey,  
                    PD.SKU,  
                    PD.Qty,  
                    --USER_NAME(), GETDATE(), USER_NAME(), GETDATE(),  
                    '',  
                    NULL,  
                    PD.Qty,  
                    '',  
                    PD.DropID,  
                    LA.Lottable06,  
                    ''  
                FROM PICKDETAIL PD WITH (NOLOCK)  
                INNER JOIN LOTATTRIBUTE LA WITH (NOLOCK)  
                ON ( PD.StorerKey = LA.StorerKey AND PD.Sku = LA.Sku AND PD.Lot = LA.Lot )  
                WHERE PD.OrderKey = @cOrderKey  
                AND PD.DropID = @c_DropID_CUR;  
            
            SET @CartonNo = @CartonNo + 1;  
            END;

            ELSE
            BEGIN
                SET @nErrNo = 267451;
                SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP'); --GenUCCLabelNo Failed. (rdt_830ExtUpd03HRP)

                CLOSE DROP_CURSOR;
                DEALLOCATE DROP_CURSOR;

                RAISERROR('GenUCCLabelNo Failed', 16, 1);
            END;   
         
            FETCH NEXT FROM DROP_CURSOR INTO @c_DropID_CUR;  
            END  
            CLOSE DROP_CURSOR;  
            DEALLOCATE DROP_CURSOR;  
  
        --------------------------------------------------------------  
            -- Insert PackInfo (IML PIPA Message)   
            --------------------------------------------------------------  
            IF NOT EXISTS (SELECT 1 FROM dbo.PackInfo WITH (NOLOCK) WHERE PickSlipNo = @cPickSlipNo)  
            BEGIN  
            SELECT @PalletWeight = MAX(deadload)  
            FROM PalletTypeMaster WITH (NOLOCK)  
            WHERE StorerKey = @cStorerKey;  

            INSERT INTO dbo.PackInfo ( PickSlipNo, CartonNo, Weight, Cube, Qty  
                                --, AddDate, AddWho, EditDate, EditWho, TrafficCop, ArchiveCop  
                                    , CartonType, RefNo, Length, Width, Height, UCCNo  
                                    , CartonGID, CartonStatus, TrackingNo )  
            SELECT  
                @cPickSlipNo  
                , DENSE_RANK() OVER (ORDER BY PD.DropID)  
                , SUM((PD.Qty * SKU.STDGrossWGT)) + ISNULL(@PalletWeight, 0)
                , SUM(PD.Qty * PK.CubeUOM3)  
                , SUM(PD.Qty)  
                --, GETDATE(), USER_NAME()  
                --, GETDATE(), USER_NAME()  
                --, ''  
                --, ''  
                , ''  
                , PD.DropID  
                , ''  
                , ''  
                , ''  
                , ''  
                , ''  
                , ''  
                , ''  
            FROM dbo.PACKDETAIL PD WITH (NOLOCK)  
            INNER JOIN dbo.SKU WITH (NOLOCK)  
                ON PD.SKU = SKU.SKU AND PD.StorerKey = SKU.StorerKey  
            INNER JOIN dbo.PACK PK WITH (NOLOCK)  
                ON PK.PackKey = SKU.PackKey  
            WHERE PD.StorerKey = @cStorerKey  
            AND PD.PickSlipNo = @cPickSlipNo  
            AND PD.DropID <> ''  
            GROUP BY PD.DropID;  
            END;  
    
            --------------------------------------------------------------  
            -- Update Wave Status to 6 (HRP requirement)  
            --------------------------------------------------------------  
            DECLARE @tWave TABLE (WaveKey NVARCHAR(20))

            INSERT INTO @tWave (WaveKey)
            SELECT DISTINCT WVM.WaveKey
            FROM dbo.WAVE WVM WITH(NOLOCK)
            INNER JOIN dbo.WAVEDETAIL WVD WITH(NOLOCK)
                ON WVM.WaveKey = WVD.WaveKey
            WHERE WVD.OrderKey = @cOrderKey
                AND WVM.Status = 5

            IF EXISTS (  
                SELECT 1
                FROM @tWave
            )  
            BEGIN  
                UPDATE WVM  
                SET WVM.Status = 6  
                FROM WAVE WVM WITH(ROWLOCK)
                INNER JOIN @tWave TW ON WVM.WaveKey = TW.WaveKey
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
                    , @b_success OUTPUT  
                    , @nErrNo OUTPUT  
                    , @cErrMsg OUTPUT;  
    
                IF @b_success <> 1
                BEGIN
                    SET @nErrNo = 267452;
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP'); --Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP)
                    RAISERROR('Insert into TRANSMITLOG3 Failed (SOCFMLOG)', 16, 1);
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
                    , @nErrNo OUTPUT  
                    , @cErrMsg OUTPUT;  
    
                IF @b_success <> 1
                BEGIN
                    SET @nErrNo = 267453;
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP'); --Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP)
                    RAISERROR('Insert into TRANSMITLOG3 Failed (PACKCFMLOG)', 16, 1);
                END;

                -- Commit transaction if we started it
                IF @nTranStarted = 1 AND @@TRANCOUNT > 0
                BEGIN
                    COMMIT TRANSACTION;
                END;

            END TRY
            BEGIN CATCH
                -- Rollback based on transaction state
                -- XACT_STATE() = -1: transaction is doomed (e.g. deadlock), must fully rollback
                -- XACT_STATE() = 1: transaction is committable, can rollback to savepoint
                IF @@TRANCOUNT > 0
                BEGIN
                    IF XACT_STATE() = -1 OR @nTranStarted = 1
                    BEGIN
                        ROLLBACK TRANSACTION;
                    END
                    ELSE IF XACT_STATE() = 1
                    BEGIN
                        ROLLBACK TRANSACTION @cSavePoint;
                    END;
                END;

                -- Cleanup cursor if open
                IF CURSOR_STATUS('local', 'DROP_CURSOR') >= 0
                BEGIN
                    CLOSE DROP_CURSOR;
                    DEALLOCATE DROP_CURSOR;
                END;

                -- Set error info if not already set
                IF @nErrNo = 0
                BEGIN
                    SET @nErrNo = 267454;
                    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP'); --Unknown Error happened
                END;

                GOTO PROC_END;
            END CATCH;

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