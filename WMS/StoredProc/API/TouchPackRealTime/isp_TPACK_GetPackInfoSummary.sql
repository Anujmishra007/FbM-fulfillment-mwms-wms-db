
/*********************************************************************************/    
/* Stored Proc: isp_TPACK_GetPackInfoSummary                                     */    
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose        : Get PackInfo Summary                                         */
/*                                                                               */
/* Date         Rev  Author     Purposes                                         */
/* 2025-08-01   1.0  GCH225     Created                                          */
/* 2026-02-05   2.0  GCH225     UWP-48241: Support Show Closed Carton status     */
/* 2026-02-11   3.0  GCH225     UWP-48267: Fix AllocQty and PickQty Null issue   */
/* 2026-04-27   3.1  GCH225     UWP-54975: Fix ToteConso display PackInfo issue  */
/*********************************************************************************/
CREATE OR ALTER PROC [API].[isp_TPACK_GetPackInfoSummary] (
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
   , @cLangCode            NVARCHAR(10)      = ''
   , @cPackInfoJson        NVARCHAR(MAX)     = 0   OUTPUT
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

   DECLARE @n_Continue              INT            = 1  
         , @n_StartCnt              INT            = @@TRANCOUNT  

         , @nTtlCurCtnPackedQty     INT
         , @nTtlPackedCtnCount      INT
         , @nTtlSkuCount            INT
         , @nTtlPackedQty           INT
         , @nTtlAllocQty            INT
         , @nTtlPickQty             INT
         , @cCurrentCartonStatus    NVARCHAR(20)
         , @cPickStsFilter1         NVARCHAR(30)
         , @nIsFilterFlag           INT
         , @nPrecedingCartonNo      INT
         , @cPrecedingCartonStatus  NVARCHAR(20)
         , @cExtPackInfoJson        NVARCHAR(MAX)
   
   DECLARE @PickQtyStatus TABLE(
        TtlPickedQty INT
      , Sku       NVARCHAR(20) 
      , [Status]  NVARCHAR(10) 
   )

   SET @b_Success                = 0  
   SET @n_ErrNo                  = 0  
   SET @c_ErrMsg                 = ''  
   SET @nTtlCurCtnPackedQty      = 0
   SET @nTtlPackedCtnCount       = 0
   SET @nTtlSkuCount             = 0
   SET @nTtlPackedQty            = 0
   SET @nTtlAllocQty             = 0
   SET @nTtlPickQty              = 0
   SET @cPackInfoJson            = ''
   SET @cCurrentCartonStatus     = ''
   SET @cPickStsFilter1          = ''
   SET @nIsFilterFlag            = 0
   SET @nPrecedingCartonNo       = 0
   SET @cPrecedingCartonStatus   = ''
   SET @cExtPackInfoJson         = '[]'

   --Get Default Total Packed Carton Count & Total Packed Qty
   IF @cPickSlipNo <> ''
   BEGIN
      SELECT  @nTtlPackedCtnCount = ISNULL(COUNT(PickSlipNo), 0) 
            , @nTtlPackedQty = ISNULL(SUM(ISNULL(Qty,0)),0)
      FROM PACKINFO (NOLOCK) 
      WHERE PickSlipNo = @cPickSlipNo
   END
   ELSE
   BEGIN
      IF @cType = 'toteid'
      BEGIN
         IF @cPickSlipNo = ''
         AND @cOrderKey = ''
         AND @cLoadKey = ''
         AND @cDropID <> ''
         BEGIN
            IF @nCartonNo > 0
            BEGIN
               SELECT TOP 1 @cPickSlipNo = ISNULL(L.PickSlipNo,'')
                              , @cOrderKey = ISNULL(L.OrderKey,'')
               FROM API.TPACK_UserSessionActivityLog L (NOLOCK)
               WHERE L.DropID = @cDropID
               AND L.EditWho = dbo.fnc_GetUserName()
               AND L.CartonNo = @nCartonNo
               -- AND NOT EXISTS (SELECT 1 
               --               FROM PACKHEADER PH (NOLOCK)
               --               WHERE PH.PickSlipNo = L.PickSlipNo
               --               AND PH.OrderKey = L.OrderKey
               --               AND PH.Status = '9'
               --      )
               ORDER BY RowRefNo DESC

               IF EXISTS (SELECT 1
                          FROM PACKHEADER PH (NOLOCK)
                          WHERE PH.PickSlipNo = @cPickSlipNo
                          AND PH.OrderKey = @cOrderKey
                          AND PH.Status = '9'
               )
               BEGIN
                  SET @cPickSlipNo = ''
                  SET @cOrderKey = ''
               END
            END

            IF @cPickSlipNo = '' AND @cOrderKey = ''
            BEGIN
               SELECT TOP 1 @cPickSlipNo = ISNULL(PH.PickSlipNo,'')
                              , @cOrderKey = ISNULL(PH.OrderKey,'')
               FROM PACKHEADER PH (NOLOCK)
               WHERE [Status] <> '9'
               AND EXISTS (SELECT 1 
                             FROM PACKDETAIL PD (NOLOCK)
                             WHERE PD.PickSlipNo = PH.PickSlipNo
                             AND PD.CartonNo = @nCartonNo
                             AND PD.DropID = @cDropID
                             AND EXISTS(
                                 SELECT 1
                                 FROM PACKINFO PIF (NOLOCK)
                                 WHERE PIF.PickSlipNo = PD.PickSlipNo
                                 AND PIF.CartonNo = PD.CartonNo
                                 AND PIF.EditWho = dbo.fnc_GetUserName()
                                 AND PIF.CartonStatus = 'INPROGRESS'
                             )
                    )
            END
         END
         
         SELECT  @nTtlPackedCtnCount = ISNULL(COUNT(PIF.PickSlipNo), 0) 
               , @nTtlPackedQty = ISNULL(SUM(ISNULL(PIF.Qty,0)),0)
         FROM PACKINFO PIF (NOLOCK) 
         WHERE (@cPickSlipNo = '' OR PIF.PickSlipNo = @cPickSlipNo)
         AND EXISTS (SELECT 1 
                     FROM PACKDETAIL PD (NOLOCK)
                     WHERE PD.PickSlipNo = PIF.PickSlipNo
                     AND PD.CartonNo = PIF.CartonNo
                     AND PD.DropID = @cDropID
                     AND EXISTS ( SELECT 1 
                                    FROM PICKDETAIL PD2 (NOLOCK)
                                    WHERE PD2.StorerKey = PD.StorerKey
                                    AND PD2.DropID = PD.DropID
                                    AND (@cOrderKey = '' OR PD2.OrderKey = @cOrderKey)
                                    AND NOT (
                                       (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD2.OrderKey) = 'E'
                                       AND PD2.[Status] = '9'
                                    )
                                 )
                     AND EXISTS (SELECT 1
                                 FROM PACKHEADER PH (NOLOCK)
                                 WHERE PD.PickSlipNo = PH.PickSlipNo
                                 AND PH.Status <> '9'
                              )
                  )
      END
   END

   IF @bIsDiscrete = 1
   BEGIN
      IF @cType = 'toteid'
      BEGIN
         -- only tote and b2c
         INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
         SELECT SUM(PD.Qty), PD.Sku, PD.[Status] 
         FROM PICKDETAIL PD (NOLOCK)
         WHERE PD.StorerKey = @cStorerKey
         AND PD.DropID = @cDropID
         AND (@cOrderKey = '' OR PD.OrderKey = @cOrderKey)
         AND NOT (
            (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
            AND PD.[Status] = '9'
         )
         AND ( @cOrderKey <> '' OR NOT EXISTS (SELECT 1
                     FROM PACKHEADER PH (NOLOCK)
                     WHERE PH.OrderKey = PD.OrderKey
                     AND PH.Status = '9'
                  )
            )
         GROUP BY PD.Sku, PD.[Status]
      END
      ELSE
      BEGIN
         INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
         SELECT SUM(PD.Qty), PD.Sku, PD.[Status] 
         FROM PICKDETAIL PD (NOLOCK)
         WHERE PD.StorerKey = @cStorerKey
         AND PD.OrderKey = @cOrderKey
         AND (@cDropID = '' OR PD.DropID = @cDropID)
         GROUP BY PD.Sku, PD.[Status]
      END

      IF @bIsCustom = 1 AND @cType = 'order'
      BEGIN
         --Get Total Packed Carton Count & Total Packed Qty
         SELECT  @nTtlPackedCtnCount = ISNULL(COUNT(DISTINCT PD.CartonNo), 0) 
               , @nTtlPackedQty = ISNULL(IIF(SUM(ISNULL(PD2.Qty,-999)) = -999 -- if pickdetail not found, then return 0 as pack qty
                                          , 0
                                          , IIF(SUM(ISNULL(PD.Qty,0)) > SUM(ISNULL(PD2.Qty,0))
                                             , SUM(ISNULL(PD2.Qty,0))
                                             , SUM(ISNULL(PD.Qty,0)) 
                                             )
                                          )
                                       , 0)  -- if total pack qty bigger than total pick qty, this is because of user pack the item at the pickslip level and go into order level and view the TotalPackQty.
         FROM PACKDETAIL PD (NOLOCK)
         LEFT JOIN PICKDETAIL PD2 (NOLOCK)
         ON PD2.CaseID = PD.LabelNo
         AND PD2.SKU = PD.SKU
         WHERE  PD.PickSlipNo = @cPickSlipNo
         AND PD2.OrderKey = @cOrderKey
         AND EXISTS (SELECT 1 
                     FROM PACKINFO PKI (NOLOCK)
                     WHERE PKI.PickSlipNO = PD.PickSlipNo
                     AND PKI.CartonNo = PD.CartonNo
                     AND PKI.CartonStatus IN ('HOLD', 'CLOSED')
         )

         --Get Default Total Packed Carton Count & Total Packed Qty
         SELECT  @nTtlPackedCtnCount = @nTtlPackedCtnCount + ISNULL(COUNT(PickSlipNo), 0) 
               , @nTtlPackedQty = @nTtlPackedQty + ISNULL(SUM(ISNULL(Qty,0)),0)
         FROM PACKINFO (NOLOCK) 
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND CartonStatus NOT IN ('HOLD', 'CLOSED')
      END
      ELSE
      BEGIN
         --Get Total Packed Carton Count & Total Packed Qty
         SELECT  @nTtlPackedCtnCount = ISNULL(COUNT(DISTINCT CartonNo), 0) 
               , @nTtlPackedQty = ISNULL(SUM(ISNULL(Qty,0)),0)
         FROM PACKDETAIL (NOLOCK) 
         WHERE  (@cPickSlipNo = '' OR PickSlipNo = @cPickSlipNo)
         AND (@cDropID = '' OR DropID = @cDropID)
      END
   END
   ELSE
   BEGIN
      IF @bIsCustom = 0
      BEGIN
         IF @cType = 'toteid'
         BEGIN
            -- only tote and b2c
            INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
            SELECT SUM(PD.Qty), PD.Sku, PD.[Status] 
            FROM PICKDETAIL PD (NOLOCK)
            WHERE PD.StorerKey = @cStorerKey
            AND (@cLoadKey = '' OR EXISTS ( SELECT 1 
                           FROM LOADPLANDETAIL LPD (NOLOCK)
                           WHERE LPD.OrderKey = PD.OrderKey
                           AND LPD.LoadKey = @cLoadKey
                           )
               )
            AND DropID = @cDropID
            AND NOT (
               (SELECT TOP 1 O.DocType FROM ORDERS O (NOLOCK) WHERE O.OrderKey = PD.OrderKey) = 'E'
               AND PD.[Status] = '9'
            )
            AND NOT EXISTS (SELECT 1
                     FROM PACKHEADER PH (NOLOCK)
                     WHERE PH.OrderKey = PD.OrderKey
                     AND PH.Status = '9'
                  )
            GROUP BY PD.Sku, PD.[Status]
         END
         ELSE
         BEGIN
            INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
            SELECT SUM(PD.Qty), PD.Sku, PD.[Status] 
            FROM PICKDETAIL PD (NOLOCK)
            WHERE PD.StorerKey = @cStorerKey
            AND EXISTS ( SELECT 1 
                           FROM LOADPLANDETAIL LPD (NOLOCK)
                           WHERE LPD.OrderKey = PD.OrderKey
                           AND LPD.LoadKey = @cLoadKey
                           )
            AND (@cDropID = '' OR PD.DropID = @cDropID)
            GROUP BY PD.Sku, PD.[Status]
         END
      END
      ELSE
      BEGIN
         INSERT INTO @PickQtyStatus (TtlPickedQty, Sku, [Status])
         SELECT SUM(PD.Qty), PD.Sku, PD.[Status] 
         FROM PICKDETAIL PD (NOLOCK)
         WHERE PD.StorerKey = @cStorerKey
         AND PD.PickSlipNo = @cPickSlipNo
         GROUP BY PD.Sku, PD.[Status]
      END
   END
   
   --Get Total Allocated Qty
   SELECT @nTtlAllocQty = ISNULL(SUM(TtlPickedQty), 0)
   FROM @PickQtyStatus
   WHERE [Status] <= '9'


   IF NOT EXISTS (SELECT 1
                  FROM STORERCONFIG (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ConfigKey = 'TPS-ShowShortPickQty' 
                  AND sValue = '1'
   )
   BEGIN
      DELETE FROM @PickQtyStatus WHERE [Status] = '4'
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
      ELSE IF EXISTS ( SELECT 1
                  FROM STORERCONFIG (NOLOCK)
                  WHERE StorerKey = @cStorerKey
                  AND ConfigKey = 'TPS-PickStatusEQ2' 
                  AND sValue = '1'
      )
      BEGIN
         SET @nIsFilterFlag = 2
         DELETE FROM @PickQtyStatus WHERE [Status] <> @cPickStsFilter1
      END

      IF NOT EXISTS (SELECT 1 FROM @PickQtyStatus)
      BEGIN
         SET @n_Continue  = 3
         SET @n_ErrNo = 11001
         SET @c_ErrMsg =  'With PickStatusFilter1(' + @cPickStsFilter1 + ') ' +
                              CASE WHEN @nIsFilterFlag = 1 THEN 'AND PickStatusLT1 enabled, '
                                   WHEN @nIsFilterFlag = 2 THEN 'AND PickStatusEQ2 enabled, '
                                   ELSE '' END +
                              API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Result No PickDetail found.'  
         GOTO EXIT_SP
      END
   END

   --Get Total SKU Count & Total Picked Qty with condition check
    SELECT @nTtlPickQty = ISNULL(SUM(TtlPickedQty), 0)
         , @nTtlSkuCount = COUNT(DISTINCT Sku) 
   FROM @PickQtyStatus

   IF @nCartonNo <> 0
   BEGIN
      IF @cType = 'toteid' 
      AND @bIsDiscrete = 0
      AND @cPickSlipNo = ''
      AND @cOrderKey = ''
      AND @cLoadKey = ''
      BEGIN
         SET @cCurrentCartonStatus = 'INPROGRESS'
         SELECT @nTtlCurCtnPackedQty = ISNULL(SUM(PD.Qty), 0)
         FROM PACKDETAIL PD (NOLOCK) 
         WHERE PD.DropID = @cDropID
         AND EXISTS ( SELECT 1 
                        FROM PACKINFO PIF (NOLOCK)
                        WHERE PIF.PickSlipNo = PD.PickSlipNo
                        AND PIF.CartonNo = PD.CartonNo
                        AND PIF.EditWho = @c_UserID
                        AND PIF.CartonStatus = @cCurrentCartonStatus
         )
      END
      ELSE
      BEGIN
         SELECT @nTtlCurCtnPackedQty = ISNULL(SUM(Qty), 0)
         FROM PACKDETAIL (NOLOCK) 
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
         AND (@cDropID = '' OR DropID = @cDropID)

         SELECT @cCurrentCartonStatus = CartonStatus
         FROM PACKINFO (NOLOCK)
         WHERE PickSlipNo = @cPickSlipNo
         AND CartonNo = @nCartonNo
      END
   END
   ELSE
   BEGIN
      --if cType is toteID, then check whether can directly navigate to first carton, if only carton count is 1.
      IF @cType = 'toteid' 
      AND @nTtlPickQty = @nTtlPackedQty
      AND ( SELECT COUNT(DISTINCT CartonNo)
            FROM PACKDETAIL (NOLOCK)
            WHERE PickSlipNo = @cPickSlipNo
            AND DropID = @cDropID
      ) = 1
      AND EXISTS (SELECT 1 
                  FROM PACKINFO(NOLOCK)
                  WHERE PickSlipNo = @cPickSlipNo
                  AND CartonStatus <> ''
      )
      BEGIN
         SELECT @nPrecedingCartonNo = P.CartonNo
              , @cPrecedingCartonStatus = P.CartonStatus
         FROM PACKINFO P (NOLOCK)
         WHERE P.PickSlipNo = @cPickSlipNo
         AND EXISTS (SELECT 1 
                     FROM PACKDETAIL PD (NOLOCK)
                     WHERE PD.PickSlipNo = P.PickSlipNo
                     AND PD.CartonNo = P.CartonNo
                     AND PD.DropID = @cDropID
                    )
         IF @@ROWCOUNT = 1
            GOTO PROCEED
      END
   END
   
   IF @cType = 'toteid'
   BEGIN
      IF NOT(@cPickSlipNo = '' AND @cOrderKey = '' AND @cLoadKey = '')
      BEGIN
         SELECT @nPrecedingCartonNo = P.CartonNo 
         FROM PACKINFO P (NOLOCK)
         WHERE P.PickSlipNo = @cPickSlipNo
         AND P.EditWho = @c_UserID
         AND P.CartonStatus = 'INPROGRESS'
         AND EXISTS (SELECT 1 
                     FROM PACKDETAIL PD (NOLOCK)
                     WHERE PD.PickSlipNo = P.PickSlipNo
                     AND PD.CartonNo = P.CartonNo
                     AND PD.DropID = @cDropID
         )
      END
      ELSE
      BEGIN
         SELECT @nPrecedingCartonNo = P.CartonNo 
         FROM PACKINFO P (NOLOCK)
         WHERE P.EditWho = @c_UserID
         AND P.CartonStatus = 'INPROGRESS'
         AND EXISTS (SELECT 1 
                     FROM PACKDETAIL PD (NOLOCK)
                     WHERE PD.PickSlipNo = P.PickSlipNo
                     AND PD.CartonNo = P.CartonNo
                     AND PD.DropID = @cDropID
         )
      END
   END
   ELSE
   BEGIN
      SELECT @nPrecedingCartonNo = CartonNo 
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND EditWho = @c_UserID
      AND CartonStatus = 'INPROGRESS'
   END

   IF @@ROWCOUNT > 1
   BEGIN
      SET @n_Continue = 3
      SET @n_ErrNo = 11002
      SET @c_ErrMsg = API.TouchPadGetMessage( @n_ErrNo, @cLangCode, 'DSP')--'Current pickslip with same EditWho user was detected more than 1 InProgress status. Kindly seek support help to rectify it.'
      GOTO EXIT_SP
   END

   IF @nPrecedingCartonNo > 0
   BEGIN
      SET @cPrecedingCartonStatus = 'INPROGRESS'
      GOTO PROCEED
   END
   
   IF @cType = 'toteid'
   BEGIN
      IF @cPickSlipNo <> ''
      BEGIN
         SELECT TOP 1 @nPrecedingCartonNo = CartonNo 
         FROM PACKDETAIL PD (NOLOCK)
         WHERE PD.PickSlipNo = @cPickSlipNo
         AND PD.DropID = @cDropID
         AND EXISTS (SELECT 1 
                     FROM PACKINFO P (NOLOCK)
                     WHERE P.PickSlipNo = PD.PickSlipNo
                     AND P.CartonNo = PD.CartonNo
                     AND P.EditWho = @c_UserID
                     AND P.CartonStatus = 'HOLD'
         )
         ORDER BY PD.EditDate DESC
      END
      ELSE
      BEGIN
         SELECT TOP 1 @nPrecedingCartonNo = CartonNo 
         FROM PACKDETAIL PD (NOLOCK)
         WHERE PD.DropID = @cDropID
         AND EXISTS (SELECT 1 
                     FROM PACKINFO P (NOLOCK)
                     WHERE P.PickSlipNo = PD.PickSlipNo
                     AND P.CartonNo = PD.CartonNo
                     AND P.EditWho = @c_UserID
                     AND P.CartonStatus = 'HOLD'
         )
      END
   END
   ELSE
   BEGIN
      SELECT TOP 1 @nPrecedingCartonNo = CartonNo 
      FROM PACKINFO (NOLOCK)
      WHERE PickSlipNo = @cPickSlipNo
      AND EditWho = @c_UserID
      AND CartonStatus = 'HOLD'
      ORDER BY EditDate DESC
   END

   IF @nPrecedingCartonNo > 0
   BEGIN
      SET @cPrecedingCartonStatus = 'HOLD'
      GOTO PROCEED
   END

PROCEED:

   EXEC [API].[isp_TPACK_ExtPackInfo_Wrapper]
     @cType                = @cType            
   , @bIsDiscrete          = @bIsDiscrete      
   , @bIsCustom            = @bIsCustom        
   , @cPickSlipNo          = @cPickSlipNo       
   , @cOrderKey            = @cOrderKey         
   , @cLoadKey             = @cLoadKey          
   , @cDropID              = @cDropID           
   , @cStorerKey           = @cStorerKey        
   , @cFacility            = @cFacility
   , @nCartonNo            = @nCartonNo
   , @c_UserID             = @c_UserID
   , @cLangCode            = @cLangCode
   , @cExtPackInfoJson     = @cExtPackInfoJson OUTPUT
   , @b_Success            = @b_Success        OUTPUT
   , @n_ErrNo              = @n_ErrNo          OUTPUT
   , @c_ErrMsg             = @c_ErrMsg         OUTPUT

   IF @b_Success = 0
   BEGIN
      SET @n_Continue = 3  
      GOTO EXIT_SP
   END
   
   SET @b_Success = 1
   SET @cPackInfoJson = ISNULL ((SELECT     @nTtlCurCtnPackedQty AS nTtlCurCtnPackedQty
                                          , @nTtlPackedCtnCount AS nTtlPackedCtnCount
                                          , @nTtlSkuCount AS nTtlSkuCount
                                          , @nTtlPackedQty AS nTtlPackedQty
                                          , @nTtlAllocQty AS nTtlAllocQty
                                          , @nTtlPickQty AS nTtlPickQty
                                          , @nPrecedingCartonNo AS nPrecedingCartonNo
                                          , @cPrecedingCartonStatus AS cPrecedingCartonStatus
                                          , @cCurrentCartonStatus AS cCurrentCartonStatus
                                          , JSON_QUERY(CASE WHEN ISJSON(@cExtPackInfoJson) = 1 
                                                               THEN @cExtPackInfoJson
                                                            ELSE '[]'
                                                            END) AS cExtPackInfoJson
                                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                                    ),'')
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