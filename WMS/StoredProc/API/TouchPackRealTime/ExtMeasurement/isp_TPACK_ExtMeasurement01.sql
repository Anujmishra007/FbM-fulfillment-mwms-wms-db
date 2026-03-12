SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_ExtMeasurement01                                   */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Extended Measurement for Update the PackInfo.                */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-03-12   1.0  GCH225     FCR-11552 Created                                */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_ExtMeasurement01] (
     @cType                NVARCHAR(30)      = ''
   , @bIsDiscrete          BIT               = 0
   , @bIsCustom            BIT               = 0
   , @cPickSlipNo          NVARCHAR(10)      = ''
   , @cOrderKey            NVARCHAR(10)      = ''
   , @cLoadKey             NVARCHAR(10)      = ''
   , @cDropID              NVARCHAR(20)      = ''
   , @cStorerKey           NVARCHAR(15)      = ''
   , @cFacility            NVARCHAR(5)       = ''
   , @nCartonNo            INT               = 0
   , @cCartonStatus        NVARCHAR(20)      = ''
   , @cCartonType          NVARCHAR(10)      = ''
   , @fWeight              FLOAT             = 0
   , @fCube                FLOAT             = 0
   , @cLabelNo             NVARCHAR(20)      = ''
   , @c_UserID             NVARCHAR(256)     = ''  
   , @cLangCode            NVARCHAR(3)       = ''
   , @fTtlWeight           FLOAT             = 0   OUTPUT
   , @fTtlCube             FLOAT             = 0   OUTPUT
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

   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT  

   SET @b_Success       = 0  
   SET @n_ErrNo         = 0  
   SET @c_ErrMsg        = ''
  
   SELECT  @fTtlWeight = IIF((ISNULL(S.STDGROSSWGT, 0) = 0), 0, ROUND((S.STDGROSSWGT * T.TtlQty), 4))
            , @fTtlCube = IIF((ISNULL(S.[Cube], 0) = 0), 0, ROUND((S.[Cube] * T.TtlQty), 4))
      FROM SKU S (NOLOCK)
      INNER JOIN (
      SELECT PD.SKU AS SKU, SUM(PD.Qty) AS TtlQty
      FROM PACKDETAIL PD (NOLOCK)
      WHERE PD.PickSlipNo = @cPickSlipNo
      AND PD.CartonNo = @nCartonNo
      GROUP BY PD.SKU
      ) T
      ON T.SKU = S.SKU
      WHERE S.StorerKey = @cStorerKey

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