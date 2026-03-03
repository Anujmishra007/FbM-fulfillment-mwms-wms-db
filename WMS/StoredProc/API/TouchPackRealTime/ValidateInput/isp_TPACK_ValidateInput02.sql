SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateInput02                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/*                                                                               */
/* Date         Rev  Author      Purposes                                        */
/* 2025-12-15   1.0  Sean        Cloned from isp_TPS_ExtValidP02 (TPS-770)       */
/* 2025-12-23   2.0  GCH225      New logic added.                                */
/*********************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPACK_ValidateInput02] (
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
   , @cInputValue2         NVARCHAR(MAX)     = ''
   , @cInputValue3         NVARCHAR(128)     = ''
   , @cScanType            NVARCHAR(20)      = ''
   , @cSKU                 NVARCHAR(20)      = ''
   , @nCartonNo            INT               = 0
   , @nQty                 INT               = 0
   , @c_UserID             NVARCHAR(256)     = ''
   , @cLangCode            NVARCHAR(3)       = ''
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

   DECLARE @nPackQTY             INT
         , @nAccumulatedPackQty  INT

   SET @b_Success = 0

   --Validate Lottable Input if found
   IF @cInputValue3 <> ''
   BEGIN
      -- Get existing packed quantity for this lottable
      SELECT @nPackQTY = ISNULL(SUM(Qty), 0)
      FROM PACKDETAIL (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND StorerKey = @cStorerKey
      AND SKU = @cSKU
      AND LOTTABLEVALUE = @cInputValue3

      SET @nAccumulatedPackQty = @nPackQTY + @nQty

      -- Validate against pick quantity for OrderKey
      IF @cOrderKey <> ''
      BEGIN
         IF NOT EXISTS(
            SELECT 1       
            FROM PICKDETAIL PD (NOLOCK)
            JOIN LOTATTRIBUTE L (NOLOCK)
            ON PD.Lot = L.Lot 
            AND PD.SKU = L.SKU
            WHERE PD.OrderKey = @cOrderKey
            AND PD.[Status] <= '5'
            AND PD.[Status] NOT IN ('4')
            AND L.Lottable02 = @cInputValue3
            GROUP BY PD.SKU, PD.OrderKey 
            HAVING SUM(PD.Qty) >= @nAccumulatedPackQty
         )
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14701
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') + '(' + @cInputValue3 + ')'
            GOTO EXIT_SP
         END
      END
      -- Validate against pick quantity for LoadKey
      ELSE IF @cLoadKey <> ''
      BEGIN
         IF NOT EXISTS(
            SELECT 1
            FROM LOADPLANDETAIL LPD (NOLOCK)
            JOIN PICKDETAIL PD (NOLOCK) 
            ON PD.OrderKey = LPD.OrderKey
            JOIN LOTATTRIBUTE L (NOLOCK)
            ON PD.Lot = L.Lot 
            AND PD.SKU = L.SKU
            WHERE LPD.LoadKey = @cLoadKey
            AND PD.[Status] <= '5'
            AND PD.[Status] NOT IN ('4')
            AND L.Lottable02 = @cInputValue3
            GROUP BY PD.SKU, PD.OrderKey 
            HAVING SUM(PD.Qty) >= @nAccumulatedPackQty
         )
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14702
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') + '(' + @cInputValue3 + ')'
            GOTO EXIT_SP
         END
      END
      -- Validate against pick quantity for PickSlipNo
      ELSE
      BEGIN
         IF NOT EXISTS(
            SELECT 1
            FROM PICKDETAIL PD (NOLOCK)
            JOIN LOTATTRIBUTE L (NOLOCK) 
            ON PD.Lot = L.Lot 
            AND PD.SKU = L.SKU
            WHERE PD.PickSlipNo = @cPickSlipNo
            AND PD.[Status] <= '5'
            AND PD.[Status] NOT IN ('4')
            AND L.Lottable02 = @cInputValue3
            GROUP BY PD.SKU, PD.OrderKey 
            HAVING SUM(PD.Qty) >= @nAccumulatedPackQty
         )
         BEGIN
            SET @n_Continue = 3
            SET @n_ErrNo = 14703
            SET @c_ErrMsg = API.TouchPadGetMessage(@n_ErrNo, @cLangCode, 'DSP') + '(' + @cInputValue3 + ')'
            GOTO EXIT_SP
         END
      END
   END

EXIT_SP:
   IF @n_Continue = 3  -- Error Occured - Process And Return      
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