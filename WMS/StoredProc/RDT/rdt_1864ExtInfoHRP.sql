SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
/********************************************************************************/  
/* Store procedure: rdt_1864ExtInfoHRP                                          */  
/*                                                                              */  
/* Purpose:       HRPUMA Project                                                */  
/*                                                                              */  
/* Date        Rev   Author   Purposes                                          */  
/* 25-04-2025  1.0   WSE016   Insert PackHeader and PackDetail data             */
/* 08-05-2025  1.1   WSE016   Copy FROM_Loc to NOTES                            */
/* 27-06-2025  1.2   WSE016   Add  Wave.Status = 6 (if all packed)              */
/* 11-07-2025  1.3   WSE016   Insert SOCFMOG into Transmitlog3 for PIPA Msg     */
/* 22-07-2025  1.4   WSE016   Insert into PackInfo for IML (PIPA Msg)           */
/*                                                                              */  
/********************************************************************************/  
CREATE OR ALTER       PROCEDURE [RDT].[rdt_1864ExtInfoHRP]
@nMobile       INT,           
@nFunc         INT,           
@cLangCode     NVARCHAR( 3),  
@nStep         INT,           
@nAfterStep    INT,           
@nInputKey     INT,           
@cFacility     NVARCHAR( 5),  
@cStorerKey    NVARCHAR( 15), 
@cPickSlipNo   NVARCHAR( 10), 
@cPickZone     NVARCHAR( 10), 
@cSuggLOC      NVARCHAR( 10), 
@cLOC          NVARCHAR( 10), 
@cID           NVARCHAR( 18),
@cSKU          NVARCHAR( 20), 
@cLottable01   NVARCHAR( 18), 
@cLottable02   NVARCHAR( 18), 
@cLottable03   NVARCHAR( 18), 
@dLottable04   DATETIME,      
@dLottable05   DATETIME,      
@cLottable06   NVARCHAR( 30), 
@cLottable07   NVARCHAR( 30), 
@cLottable08   NVARCHAR( 30), 
@cLottable09   NVARCHAR( 30), 
@cLottable10   NVARCHAR( 30), 
@cLottable11   NVARCHAR( 30), 
@cLottable12   NVARCHAR( 30), 
@dLottable13   DATETIME,      
@dLottable14   DATETIME,      
@dLottable15   DATETIME,      
@nTaskQTY      INT,           
@cToLOC        NVARCHAR( 10), 
@cOption       NVARCHAR( 1),  
@cExtendedInfo NVARCHAR( 20) OUTPUT, 
@nErrNo        INT           OUTPUT, 
@cErrMsg       NVARCHAR( 20) OUTPUT 

AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

 DECLARE 
  @cOrderKey AS NVARCHAR(20)
, @nFullyPicked AS INT
, @cLoadKey AS NVARCHAR(20)
, @nTTLCNTS AS INT
, @cOrderType AS NVARCHAR(20)
, @c_StorerKey NVARCHAR(15)  = @cStorerKey 
, @c_LabelNo   NVARCHAR(20)
, @b_success   Int 
, @n_err       Int 
, @c_errmsg    NVARCHAR(225) 
, @n_continue  Int
, @c_Key1 NVARCHAR( 30)
, @PalletWeight DECIMAL (10,2)



-- to get LabelNo for Packing
    EXECUTE isp_GenUCCLabelNo
                  @c_StorerKey,
                  @c_LabelNo  OUTPUT,
                  @b_success  OUTPUT,
                  @n_err      OUTPUT,
                  @c_errmsg   OUTPUT

    IF @b_success = 0
        BEGIN
            GOTO PROC_END
        END         



SELECT TOP 1
    @cOrderKey = OrderKey, @cLoadKey = LoadKey
FROM PICKHEADER WITH(NOLOCK)
WHERE PickHeaderKey = @cPickSlipNo

SELECT TOP 1
    @nTTLCNTS = COUNT(DISTINCT DropID)
FROM PICKDETAIL WITH(NOLOCK)
WHERE OrderKey = @cOrderKey AND DropID <> ''

SELECT TOP 1
    @cOrderType = Type
FROM ORDERS WITH(NOLOCK)
where StorerKey = @cStorerKey and OrderKey in (
  SELECT OrderKey
    FROM PICKHEADER WITH(NOLOCK)
    WHERE OrderKey = @cOrderKey)


IF EXISTS (SELECT 1 FROM ORDERDETAIL WITH(NOLOCK) WHERE StorerKey = @cStorerKey  and OrderKey = @cOrderKey HAVING SUM(OriginalQty) = SUM(QtyPicked))
   BEGIN
      SET @nFullyPicked = 1
   END

   ELSE
   BEGIN
      SET @nFullyPicked = 0
   END

   SET @cExtendedInfo = ''
   SET @nErrNo = 0
   SET @cErrMsg = ''



IF @nFunc = 1864 -- PalletPicking

BEGIN
    IF @nAfterStep = 3 -- LOC

IF EXISTS (SELECT 1
    FROM PICKDETAIL WITH (NOLOCK)
    WHERE storerkey = @cStorerKey AND loc = @cLOC AND OrderKey IN (
        SELECT OrderKey
        FROM PICKHEADER WITH (NOLOCK)
        WHERE storerkey = @cStorerKey AND PickHeaderKey = @cPickSlipNo)
         )

        BEGIN
         UPDATE PICKDETAIL SET NOTES = @cLOC WHERE storerkey = @cStorerKey AND loc = @cLOC AND OrderKey IN (
            SELECT OrderKey
            FROM PICKHEADER WITH (NOLOCK)
            WHERE storerkey =@cStorerKey AND PickHeaderKey = @cPickSlipNo)
    END





IF @nStep = 5 AND @nFullyPicked = 1 AND @cOrderType = 'ZPTO'

BEGIN
    IF NOT EXISTS (SELECT 1
    FROM PackHeader WITH(NOLOCK)
    WHERE OrderKey = @cOrderKey)
	  BEGIN
        INSERT INTO PackHeader
        VALUES
            (@cPickSlipNo, @cStorerKey, '', @cOrderKey, '', @cLoadKey, '', '9', USER_NAME(), GETDATE(), USER_NAME(), GETDATE(), NULL, @nTTLCNTS, '', '', '', '', '', 0, 0, 0, 0, 0, 0, 0, 'STD', 0, '', '', '', 0, 0)
    END

    IF NOT EXISTS (SELECT 1
    FROM PackDetail WITH(NOLOCK)
    WHERE PickSlipNo = @cPickSlipNo)
	  BEGIN
        INSERT INTO PackDetail
        SELECT @cPickSlipNo, DENSE_RANK()OVER(ORDER BY DropID) CartonNo,
            --DropID LabelNo, 
            @c_LabelNo LabelNo, -- replace DropId With LabelNo to match Fn838
            RIGHT('0000'+CONVERT(NVARCHAR(10),ROW_NUMBER()OVER(PARTITION BY DropID ORDER BY DropID)),5) LabelLine, @cStorerKey, SKU, Qty, USER_NAME(), GETDATE(), USER_NAME(),
            GETDATE(), '', NULL, Qty, '', DropID, '', ''
        FROM PICKDETAIL WITH(NOLOCK)
        WHERE OrderKey = @cOrderKey
            AND DropID <> ''
       END


-- WSE016 Insert to PACKINFO for IML (PIPA message)

    IF NOT EXISTS (
        SELECT 1
        FROM PackInfo WITH (NOLOCK)
        WHERE PickSlipNo = @cPickSlipNo
    )
    BEGIN

    -- Step 1: Get max dead load from pallet type master
        SELECT 
            @PalletWeight = MAX(deadload) 
        FROM PalletTypeMaster WITH (NOLOCK) 
        WHERE StorerKey = @cStorerKey;
 
  -- Step 2: Calculate and Insert carton-level metrics
    INSERT INTO PackInfo
        SELECT 
            @cPickSlipNo AS PickSlipNo,
            DENSE_RANK() OVER (ORDER BY PD.DropID) AS CartonNo,
            SUM((PD.Qty * SKU.STDGrossWGT) + @PalletWeight) AS [Weight],
            SUM(PD.Qty * PK.CubeUOM3) AS [Cube],
            SUM(PD.Qty) AS Qty,
            GETDATE() AS AddDate,
            USER_NAME() AS AddWho,
            GETDATE() AS Editdate,
            USER_NAME() AS EditWho,
            '' AS TrafficCop,
            '' AS ArchiveCop,
            '' AS CartonType,
            PD.DropID AS RefNo,
            '' AS [Length],
            '' AS [Width],
            '' AS [Height],
            '' AS UCCNo,
            '' AS CartonGID,
            '' AS CartonStatus,
            '' AS TrackingNo
        FROM PACKDETAIL PD WITH (NOLOCK)
        INNER JOIN SKU WITH (NOLOCK) ON PD.SKU = SKU.SKU and  SKU.StorerKey = PD.StorerKey
        INNER JOIN PACK PK WITH (NOLOCK) ON PK.PackKey = SKU.PackKey
        WHERE PD.StorerKey = @cStorerKey
            AND PD.PickSlipNo = @cPickSlipNo
            AND PD.DropID <> ''
        GROUP BY 
        PD.DropID
    END



	-- change wave Status tp 6 (Status only for this project)
	IF EXISTS
	(
	    SELECT 1
	    FROM WAVE WVM WITH (NOLOCK)
	        INNER JOIN WAVEDETAIL WVD WITH (NOLOCK)
	            ON WVM.WaveKey = WVD.WaveKey
	    WHERE WVD.OrderKey = @cOrderKey
	          AND WVM.[Status] = 5
	)
	BEGIN
	    UPDATE WVM
	    SET WVM.[Status] = 6
	    FROM WAVE WVM
	        INNER JOIN WAVEDETAIL WVD
	            ON WVM.WaveKey = WVD.WaveKey
	    WHERE WVD.OrderKey = @cOrderKey
	          AND WVM.[Status] = 5
    	END


-- Trigger for PIPA message to PUMA (this has been disabled in  ITFTriggerConfig )
        EXEC dbo.ispGenTransmitLog3 'SOCFMLOG', @cOrderKey, '', @cStorerKey, ''
             , @b_success =''
             , @n_err =''
             , @c_errmsg =''


            IF @b_success <> 1
            BEGIN
                SET @n_continue = 3
                SET @n_err = 218377  
                SET @c_errmsg
                    = 'NSQL' + CONVERT(CHAR(5), ISNULL(@n_err, 0))
                    + ': Insert into TRANSMITLOG3 Failed. (rdt_1864ExtInfoHRP) ( SQLSvr MESSAGE = '
                    + ISNULL(LTRIM(RTRIM(@c_errmsg)), '') + ' ) '
                GOTO PROC_END
            END

-- Insert records into Transmitlog3 (PGI_OUT IML message)

        SET @c_Key1 = 'O' + @cOrderKey

        EXEC dbo.ispGenTransmitLog3 'PACKCFMLOG',
                                @cPickSlipNo,
                                @c_Key1,
                                @cStorerKey,
                                '',
                                @b_success OUTPUT,
                                @n_err OUTPUT,
                                @c_errmsg OUTPUT

        IF @b_success <> 1
        BEGIN
            SET @n_continue = 3
            SET @n_err = 218365  
            SET @c_errmsg
                = 'NSQL' + CONVERT(CHAR(5), ISNULL(@n_err, 0))
                + ': Insert into TRANSMITLOG3 Failed. (rdt_1864ExtInfoHRP) ( SQLSvr MESSAGE = '
                + ISNULL(LTRIM(RTRIM(@c_errmsg)), '') + ' ) '
            GOTO PROC_END
        END
		  
END

END
   PROC_END:

END
GO
