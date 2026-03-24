SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateQtyPack                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Validate Packed Qty versus Pick Qty                          */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-07   1.0  GCH225     Created                                          */
/* 2026-03-18   1.1  JWF011     UWP-52263: Add config to check UPC QTY           */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ValidateQtyPack] (
	  @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @cInputValue1         NVARCHAR(128)     = ''
   , @cScanType            NVARCHAR(20)      = ''
   , @cSKU                 NVARCHAR(20)      = ''
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @nQty                 INT               = 0
   , @b_Success            INT               = 0   OUTPUT
   , @n_ErrNo              INT               = 0   OUTPUT
   , @c_ErrMsg             NVARCHAR(250)     = ''  OUTPUT
)
AS
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_DEFAULTS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @n_Continue           INT            = 1  
         , @n_StartCnt           INT            = @@TRANCOUNT  

         , @nPickQty             INT
         , @nPackedQty           INT
         , @cPickStsFilter1      NVARCHAR(30)
         , @nIsFilterFlag        INT
         , @bIsMixPackingMode    BIT --User perform more than two different Type of packing. Either pickslip with toteid or order   
         , @nTtlPackedQty        INT
         , @nCartonNo            INT
         , @nAvailableQty        INT
         , @nInPackedQty         INT
   
   DECLARE @PickQtyStatus TABLE(
        TtlPickedQty INT
      , [Status] NVARCHAR(10) 
   )

   SET @b_Success          = 0  
   SET @n_ErrNo            = 0  
   SET @c_ErrMsg           = '' 
   SET @nPickQty           = 0
   SET @nPackedQty         = 0
   SET @cPickStsFilter1    = ''
   SET @nIsFilterFlag      = 0
   SET @bIsMixPackingMode  = 0
   SET @nTtlPackedQty      = 0
   SET @nCartonNo          = 0
   SET @nAvailableQty      = 0
   SET @nInPackedQty       = 0

   IF @cScanType = 'upc'
   BEGIN
      IF EXISTS( SELECT 1 
                  FROM STORERCONFIG (NOLOCK)
                  WHERE Storerkey = @cStorerKey
                  AND ConfigKey = 'TPS-CheckUPCQTY'
                  AND SValue = '1'
      )
      BEGIN
         IF EXISTS ( SELECT 1
                     FROM PACKDETAIL(NOLOCK)
                     WHERE StorerKey = @cStorerKey 
                     AND SKU = @cSKU
                     AND PickSlipNo = @cPickSlipNo
                     AND UPC = @cInputValue1
                     HAVING COALESCE(SUM(Qty), 0) 
                     + @nQty > (SELECT Qty 
                              FROM UPC (NOLOCK)
                              WHERE StorerKey = @cStorerKey
                              AND SKU = @cSKU
                              AND UPC = @cInputValue1 
                              ) 
         )
         BEGIN
            SET @n_Continue  = 3
            SET @n_ErrNo = 11451
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Exceed Total Pack Qty versus UPC Qty.'
            GOTO EXIT_SP
         END
      END
   END

   --Get Standard PackQty from Pickslip level.
   SELECT @nPackedQty = ISNULL(SUM(PD.Qty), 0) 
   FROM PACKDETAIL PD(NOLOCK)
   WHERE PD.StorerKey = @cStorerKey 
   AND PD.SKU = @cSKU
   AND PD.PickSlipNo = @cPickSlipNo

   IF @cType = 'order'
   BEGIN
      --Different logic to check exceed pack, due to every carton close/hold will update the labelno to caseID therefore can directly check the remaining qty as available qty to compare upcoming qty.
      IF @bIsCustom = 1
      BEGIN
         SET @nPackedQty = 0
         SET @nAvailableQty = 0
         -- this condition is because the pickdetail CaseID havent update to blank therefore cannot filter the labelNo with CaseID
         -- after the first carton close, the pickdetail will have some label no update and other will be clear therefore the else condition for PD2.CaseID need to filter ''
         SELECT @nCartonNo = ISNULL(CartonNo, 0)
         FROM PACKINFO (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         GROUP BY CartonNo
         HAVING COUNT(CartonNo) = 1
         
         IF @nCartonNo <= 1
         BEGIN
            SELECT @nAvailableQty = ISNULL(SUM(Qty), 0) 
            FROM PICKDETAIL PD(NOLOCK)
            WHERE PD.OrderKey = @cOrderKey
            AND PD.SKU = @cSKU
         END
         ELSE
         BEGIN
            SELECT @nAvailableQty = ISNULL(SUM(Qty), 0)
            FROM PICKDETAIL PD(NOLOCK)
            WHERE PD.OrderKey = @cOrderKey
            AND PD.SKU = @cSKU
            AND PD.CaseID = ''
         END

         SELECT @nInPackedQty = ISNULL(SUM(PD.Qty), 0)
         FROM PACKDETAIL PD (NOLOCK)
         WHERE PD.PickSlipNo = @cPickSlipNo
         AND PD.SKU = @cSKU
         AND EXISTS( SELECT 1 
                     FROM PACKINFO PKI (NOLOCK)
                     WHERE PKI.PickSlipNo = PD.PickSlipNo
                     AND PKI.CartonNo = PD.CartonNo
                     AND PKI.CartonStatus = 'INPROGRESS'
         )

         IF @nQty > (@nAvailableQty - @nInPackedQty)
         BEGIN
            SET @n_Continue  = 3
            SET @n_ErrNo = 11456
            SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Exceed Total Pack Qty versus Pick Qty.'
            GOTO EXIT_SP
         END
      END
   END
   ELSE IF @cType = 'toteid'
   BEGIN
      SET @nPackedQty = 0
      
      IF (SELECT ISNULL(SUM(PD.Qty), 0)
          FROM PACKDETAIL PD(NOLOCK)
          WHERE PD.StorerKey = @cStorerKey 
          AND PD.SKU = @cSKU
          AND PD.PickSlipNo = @cPickSlipNo
          AND PD.DropID = ''
      ) > 0
      BEGIN
         SET @bIsMixPackingMode = 1
      END

      SELECT @nPackedQty = ISNULL(SUM(PD.Qty), 0) 
      FROM PACKDETAIL PD(NOLOCK)
      WHERE PD.StorerKey = @cStorerKey 
      AND PD.SKU = @cSKU
      AND PD.PickSlipNo = @cPickSlipNo
      AND PD.DropID = @cDropID

      IF @bIsMixPackingMode = 1
      BEGIN
         -- If any quantity is packed for the current DropID, include additional packed quantities for the same SKU and PickSlipNo from other DropIDs.
         SELECT @nPackedQty = @nPackedQty + ISNULL(SUM(PD.Qty), 0) 
         FROM PACKDETAIL PD(NOLOCK)
         WHERE PD.StorerKey = @cStorerKey 
         AND PD.SKU = @cSKU
         AND PD.PickSlipNo = @cPickSlipNo
         AND NOT EXISTS (SELECT 1
                         FROM PACKDETAIL PD2(NOLOCK)
                         WHERE PD2.PickSlipNo = PD.PickSlipNo
                         AND PD2.CartonNo = PD.CartonNo
                         AND PD2.LabelNo = PD.LabelNo
                         AND PD2.LabelLine = PD.LabelLine
                         AND PD2.DropID = @cDropID
                        )
      END
   END

   SET @nTtlPackedQty = @nPackedQty + @nQty

   IF @nTtlPackedQty = 0
   BEGIN
      GOTO EXIT_SP
   END

   IF @bIsDiscrete = 1
   BEGIN
      INSERT INTO @PickQtyStatus (TtlPickedQty, [Status])
      SELECT SUM(Qty), [Status] 
      FROM PICKDETAIL (NOLOCK)
      WHERE OrderKey = @cOrderKey
      AND (@cDropID = '' OR DropID = @cDropID)
      AND SKU = @cSKU
      AND [Status] < 9
      GROUP BY [Status]
   END
   ELSE
   BEGIN
      IF @bIsCustom = 0
      BEGIN
         INSERT INTO @PickQtyStatus (TtlPickedQty, [Status])
         SELECT SUM(Qty), [Status] 
         FROM PICKDETAIL PD (NOLOCK)
         WHERE EXISTS ( SELECT 1 
                        FROM LOADPLANDETAIL LPD (NOLOCK)
                        WHERE LPD.OrderKey = PD.OrderKey
                        AND LPD.LoadKey = @cLoadKey
                        )
         AND (@cDropID = '' OR DropID = @cDropID)
         AND SKU = @cSKU
         AND [Status] < 9
         GROUP BY [Status]
      END
      ELSE
      BEGIN
         INSERT INTO @PickQtyStatus (TtlPickedQty, [Status])
         SELECT SUM(Qty), [Status] 
         FROM PICKDETAIL PD (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND SKU = @cSKU
         AND [Status] < 9
         GROUP BY [Status]
      END
   END

   IF NOT EXISTS (SELECT 1
                  FROM STORERCONFIG (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ConfigKey = 'TPS-ShowShortPickQty' 
                  AND sValue = '1'
   )
   BEGIN
      DELETE FROM  @PickQtyStatus WHERE [Status] = '4'
   END

   SELECT @cPickStsFilter1 = sValue
   FROM STORERCONFIG (NOLOCK)
   WHERE StorerKey = @cStorerKey
   AND ConfigKey = 'TPS-PickStatusFilter1' 

   IF @@ROWCOUNT <> 0
   AND ISNULL(@cPickStsFilter1,'') <> '' 
   AND ISNUMERIC(@cPickStsFilter1) = 1 
   AND LEN(@cPickStsFilter1) = 1 
   AND @cPickStsFilter1 COLLATE Latin1_General_BIN LIKE '[0-9]' 
   BEGIN
      IF EXISTS ( SELECT 1
                  FROM STORERCONFIG (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ConfigKey = 'TPS-PickStatusLT1' 
                  AND sValue = '1'
      )
      BEGIN
         SET @nIsFilterFlag = 1
         DELETE FROM @PickQtyStatus WHERE [Status] > @cPickStsFilter1
      END
      ELSE IF EXISTS (  SELECT 1
                        FROM STORERCONFIG (NOLOCK)
                        WHERE StorerKey = @cStorerKey
                        AND ConfigKey = 'TPS-PickStatusEQ2' 
                        AND sValue = '1'
      )
      BEGIN
         SET @nIsFilterFlag = 2
         DELETE FROM @PickQtyStatus WHERE [Status] <> @cPickStsFilter1
      END

      IF NOT EXISTS (SELECT 1 
                     FROM @PickQtyStatus
      )
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11452
         SET @c_ErrMsg =  'With PickStatusFilter1(' + @cPickStsFilter1 + ') ' +
                              CASE WHEN @nIsFilterFlag = 1 THEN 'AND PickStatusLT1 enabled, '
                                   WHEN @nIsFilterFlag = 2 THEN 'AND PickStatusEQ2 enabled, '
                                   ELSE '' END +
                              API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'No PickDetail Result Found.'  
         GOTO EXIT_SP
      END
   END

   SELECT @nPickQty = ISNULL(SUM(TtlPickedQty), 0)
   FROM @PickQtyStatus

   IF @nPickQty = 0
   BEGIN
      SET @n_Continue  = 3
      SET @n_ErrNo = 11455
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Pick Qty cannot be zero.'
      GOTO EXIT_SP
   END

   IF @nTtlPackedQty > @nPickQty
   BEGIN
      SET @n_Continue  = 3
      SET @n_ErrNo = 11453
      SET @c_ErrMsg =  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Exceed Total Pack Qty versus Pick Qty.'
      GOTO EXIT_SP
   END

PROCEED:

EXIT_SP:
   IF @n_Continue= 3  -- Error Occured - Process And Return      
   BEGIN      
      SET @b_Success = 0      
      IF @@TRANCOUNT > @n_StartCnt AND @@TRANCOUNT = 1 
      BEGIN               
         ROLLBACK TRAN      
      END      
      ELSE      
      BEGIN      
         WHILE @@TRANCOUNT > @n_StartCnt      
         BEGIN      
            COMMIT TRAN      
         END      
      END   
      RETURN      
   END      
   ELSE      
   BEGIN      
      SELECT @b_Success = 1      
      WHILE @@TRANCOUNT > @n_StartCnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END
END



