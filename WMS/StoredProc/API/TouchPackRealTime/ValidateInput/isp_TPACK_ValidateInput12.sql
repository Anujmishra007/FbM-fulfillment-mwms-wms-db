SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/
/* Store procedure: isp_TPACK_ValidateInput12                                    */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2026-08-17   1.0  GCH225     UWP-27857: Created                               */
/*********************************************************************************/

CREATE  OR ALTER PROC [API].[isp_TPACK_ValidateInput12] (
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

   DECLARE @n_Continue     INT            = 1  
         , @n_StartCnt     INT            = @@TRANCOUNT  
         , @cSerialNo      NVARCHAR(50)
         , @cSNOrderKey    NVARCHAR(10)
         , @dSNAddDate     DATE
         , @bTID_Exist     BIT           
         , @bPickMethod    BIT
         , @cSerialNoType  NVARCHAR(1)
         , @nPallet        FLOAT
         , @nCaseCnt       FLOAT
         , @cBUSR7         NVARCHAR(50)
         , @nPalletQty     FLOAT
         , @nCtnPerPL      INT

   DECLARE @SCANSERIAL TABLE                    
   (  SerialNo NVARCHAR(30) NOT NULL PRIMARY KEY
   ,  Qty      INT          NOT NULL DEFAULT(0) 
   )

   SET @b_Success       = 0
   SET @cSerialNo       = ''
   SET @cSNOrderKey     = ''
   SET @dSNAddDate      = NULL
   SET @bTID_Exist      = 0
   SET @bPickMethod     = 0
   SET @cSerialNoType   = ''
   SET @nPallet         = 0
   SET @nCaseCnt        = 0
   SET @cBUSR7          = ''
   SET @nPalletQty      = 0
   SET @nCtnPerPL       = 0

   SELECT @cSerialNo = ISNULL([value], '')
   FROM OPENJSON(@cInputValue2)
   WITH ([value] NVARCHAR(100) '$') J

   SET @cSerialNoType = RIGHT(RTRIM(@cSerialNo),1) 

   IF @cSerialNo = ''
   BEGIN
      SET @n_Continue = 3
      GOTO EXIT_SP
   END

   IF LEN(@cSerialNo) <> 12
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 1001
      SET @c_ErrMsg = 'Invalid Serial Number Length. Expected 12 characters.'
      GOTO EXIT_SP
   END

   IF @cSerialNoType NOT IN ('P','M', 'C', '9')
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 1002
      SET @c_ErrMsg = 'Invalid Serial Number Format. Last character must be P, M, C, or 9.'
      GOTO EXIT_SP
   END

   IF @cSerialNo NOT LIKE '%[^A-Z0-9]%'
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 1003
      SET @c_ErrMsg = 'Invalid Serial Number Format. Must contain only uppercase letters and digits.'
      GOTO EXIT_SP
   END

   IF LEFT(@cSerialNo, 4) NOT LIKE '%[^0-9]%'
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 1004
      SET @c_ErrMsg = 'Invalid Serial Number Format. First four characters must be digits.'
      GOTO EXIT_SP
   END

   IF SUBSTRING(@cSerialNo, 5, 2) NOT LIKE '%[^A-Z]%'
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 1005
      SET @c_ErrMsg = 'Invalid Serial Number Format. Characters 5 and 6 must be uppercase letters.'
      GOTO EXIT_SP
   END

   IF @cSerialNoType = 'P'
   BEGIN
      SELECT @nCaseCnt = P.CaseCnt
            ,@nPallet  = P.Pallet
            ,@cBUSR7   = ISNULL(RTRIM(S.BUSR7),'')
      FROM SKU S WITH (NOLOCK)
      JOIN PACK P WITH (NOLOCK) 
      ON S.Packkey = P.Packkey
      WHERE S.Storerkey = @cStorerKey
      AND S.Sku = @cSKU

      IF @@ROWCOUNT = 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 16602
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--PACK Pallet quantity cannot be zero, null or not maintained in the system for this SKU. Please contact your supervisor.
         GOTO EXIT_SP
      END

      IF @cBUSR7 <> 'Yes'
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 1006
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') -- Invalid Pallet Serial#:
         GOTO EXIT_SP
      END

      INSERT INTO @SCANSERIAL (SerialNo, Qty)
      SELECT TID.TrackingID
            ,TID.Qty
      FROM TRACKINGID TID WITH (NOLOCK)
      WHERE TID.ParentTrackingID = @cSerialNo
      AND TID.Storerkey = @cStorerKey
      AND TID.PickMethod <> 'loose'              
      AND TID.[Status] >= 1 AND TID.[Status] <= 9
   
      SET @nCtnPerPL = @@ROWCOUNT

      SET @nPalletQty = @nCaseCnt * @nCtnPerPL

      IF @nPalletQty > @nPallet AND @nPallet > 0
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 60050                                                                                          
         SET @c_ErrMsg= API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + RTRIM(@cSerialNo) + '. ' -- Pallet Count Qty > Sku's Pallet setup in PACK table. Serial#: ' 
         GOTO EXIT_SP            
      END
   END
   ELSE
   BEGIN
      INSERT INTO @SCANSERIAL (SerialNo)
      VALUES (@cSerialNo)
   END 

   IF EXISTS ( SELECT 1
               FROM @SCANSERIAL SS                                                                         
               JOIN SERIALNO SN WITH (NOLOCK) 
               ON SN.SerialNo = SS.SerialNo                              
               JOIN fnc_GetWaveOrder_DropID (@cDropID) TOTEORD
               ON (SN.Orderkey = TOTEORD.Orderkey)                                                 
               WHERE SN.Storerkey = @cStorerKey
               AND SN.ExternStatus <> 'CANC'
   )
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 60010                                                                                           
      SET @c_ErrMsg= API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + RTRIM(@cSerialNo) + '. ' -- Duplicate Serial #: 
      GOTO EXIT_SP
   END

   IF EXISTS ( SELECT 1
               FROM @SCANSERIAL SS                                                   
               JOIN SERIALNO SN WITH (NOLOCK) ON SN.SerialNo = SS.SerialNo                                 
               WHERE SN.Storerkey = @cStorerKey                    
               AND SN.ExternStatus <> 'CANC'
               AND EXISTS ( SELECT 1 FROM PACKDETAIL PD WITH (NOLOCK)
                              WHERE PD.PickSlipNo = SN.PickSlipNo   
                              AND   PD.CartonNo   = SN.CartonNo  
                              AND   PD.LabelLine  = SN.LabelLine
                           )
               --AND SN.AddDate BETWEEN DATEADD(HH, -24, GETDATE()) AND GETDATE() 
               AND SN.AddDate BETWEEN CONVERT(DATETIME, CONVERT(NVARCHAR(10), GETDATE(), 121))
                              AND CONVERT(DATETIME, CONVERT(NVARCHAR(10), GETDATE(), 121) + ' 23:59:59')
   )
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 60011                                                                                           
      SET @c_ErrMsg=  API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + RTRIM(@cSerialNo) + '. ' --SerialNo had been packed.
      GOTO EXIT_SP
   END

   IF @cSerialNoType = 'P'
   BEGIN
      IF NOT( 
         EXISTS ( 
            SELECT 1
            FROM TrackingID (NOLOCK)
            WHERE StorerKey = @cStorerKey
            AND SKU = @cSKU
            AND ParentTrackingID = @cSerialNo
      )
      AND EXISTS (
            SELECT 1 
            FROM MASTERSERIALNO (NOLOCK)
            WHERE Storerkey = @cStorerKey
            AND Sku = @cSKU
            AND ParentSerialNo = @cSerialNo
         )
      )
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 1009
         SET @c_ErrMsg = 'Invalid Parent Serial Number. Must exist in TrackingID and MasterSerialNo.'
         GOTO EXIT_SP
      END
   END

   IF @cSerialNoType IN ('P', 'M')
   BEGIN
      SELECT 1
      FROM TrackingID (NOLOCK)
      WHERE StorerKey = @cStorerKey
      AND SKU = @cSKU
      AND (
         (@cSerialNoType = 'P' AND ParentTrackingID = @cSerialNo)
      OR (@cSerialNoType = 'M' AND TrackingID = @cSerialNo)
      )
      AND [Status] >= '1'
      AND [Status] < '9'
      AND PickMethod <> ''

      IF @@ROWCOUNT = 1
      BEGIN
         SET @n_Continue = 3
         SET @n_ErrNo = 1010
         SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP') + RTRIM(@cSerialNo) + '. ' --'SerialNo already packed. Serial#: ' + RTRIM(@cSerialNo)
         GOTO EXIT_SP
      END
   END
   --Migrate to custom ValidateQtyPack
   -- IF @c_SerialNoType IN ('P')      
   --    BEGIN
   --       IF @n_PLQty <> @n_Qty 
   --       BEGIN
   --          SET @n_Continue = 3
   --          SET @n_err = 60032                                                                                         
   --          SET @c_errmsg= 'NSQL'+ CONVERT(CHAR(5),@n_err)+': Scanned Qty <> Pallet Count Qty. Serial#:' 
   --                       + RTRIM(@c_SerialNo) + '. (isp_DropIDSN01)' 
   --          GOTO QUIT_SP            
   --       END

   --       SELECT TOP 1 @c_Wavekey  = Wavekey  
   --       FROM dbo.fnc_GetWaveOrder_DropID(@c_DropID);    

   --       SELECT @n_QtyAllocated = ISNULL(SUM(PD.Qty),0)  
   --       FROM PICKDETAIL PD WITH (NOLOCK)  
   --       JOIN WAVEDETAIL WD WITH (NOLOCK) ON (PD.Orderkey = WD.Orderkey)  
   --       WHERE PD.DropID = @c_DropID  
   --       AND   WD.Wavekey= @c_Wavekey  
   --       AND   PD.Storerkey = @c_Storerkey  
   --       AND   PD.Sku = @c_Sku
          
   --       SELECT @n_QtyPacked = ISNULL(SUM(PD.Qty),0)  
   --       FROM PACKHEADER PH WITH (NOLOCK)   
   --       JOIN PACKDETAIL PD WITH (NOLOCK) ON (PH.PickSlipNo = PD.PickSlipNo)  
   --       JOIN WAVEDETAIL WD WITH (NOLOCK) ON (PH.Orderkey = WD.Orderkey)  
   --       WHERE PD.DropID = @c_DropID  
   --       AND   WD.Wavekey= @c_Wavekey  
   --       AND   PD.Storerkey = @c_Storerkey  
   --       AND   PD.Sku = @c_Sku  
           
   --       IF @n_QtyAllocated - @n_QtyPacked > @n_PLQty
   --       BEGIN
   --          SET @n_continue = 3                                                                                              
   --          SET @n_err = 60070                                                                                        
   --          SET @c_errmsg='NSQL'+ CONVERT(CHAR(5),@n_err)+': Pack Qty > Pick Qty. (isp_DropIDSN01)' 
                                                                                                                      
   --          GOTO QUIT_SP          
   --       END
   --    END
   --    ELSE
   --    BEGIN
   --       IF (dbo.fnc_GetOrder_DropID (@c_DropID, @c_Storerkey, @c_Sku, @n_Qty)) = ''
   --       BEGIN
   --          SET @n_continue = 3                                                                                              
   --          SET @n_err = 60030                                                                                        
   --          SET @c_errmsg='NSQL'+ CONVERT(CHAR(5),@n_err)+': Pack Qty > Pick Qty. (isp_DropIDSN01)' 
                                                                                                                      
   --          GOTO QUIT_SP  
   --       END
   --    END

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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON [API].[isp_TPACK_ValidateInput12] TO NSQL
GO