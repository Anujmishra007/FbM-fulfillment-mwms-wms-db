SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************/
/* Store procedure: isp_TPACK_RecartonBlocked01                                  */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Custom Recarton Blocked Logic                                */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-05-21   1.0  GCH225     FCR-13334: Created                               */
/*********************************************************************************/

CREATE OR ALTER PROC [API].[isp_TPACK_RecartonBlocked01] (
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

   DECLARE @n_Continue        INT            = 1  
         , @n_StartCnt        INT            = @@TRANCOUNT  


   DECLARE  @tPickedItem TABLE (
        SKU      NVARCHAR(20)
      , Qty      INT
   )

   DECLARE  @tPackedItem TABLE (
        SKU      NVARCHAR(20)
      , Qty      INT
   )

   IF @cPickSlipNo <> '' AND @nCartonNo <> 0 AND @cDropID <> ''
   BEGIN
      INSERT INTO @tPackedItem (SKU, Qty)
      SELECT SKU, SUM(Qty)
      FROM PACKDETAIL (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND CartonNo = @nCartonNo
      AND DropID = @cDropID
      GROUP BY SKU
   END

   IF @cDropID <> '' 
   AND @cOrderKey <> '' 
   BEGIN
      INSERT INTO @tPickedItem (SKU, Qty)
      SELECT  PD1.SKU AS SKU
            , ISNULL(SUM(PD1.Qty), 0) - ISNULL(SUM(PD2.Qty), 0) AS Qty
      FROM PICKDETAIL PD1 (NOLOCK)
      LEFT JOIN @tPackedItem PD2
      ON PD1.SKU = PD2.SKU          
      WHERE PD1.OrderKey = @cOrderKey
      AND PD1.DropID = @cDropID
      GROUP BY PD1.SKU

      IF EXISTS (
         SELECT 1
         FROM @tPickedItem P
         WHERE P.Qty > 0
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 16101
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')  -- 'Recarton Blocked: There are still picked items not packed yet.'
         GOTO EXIT_SP
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
GO