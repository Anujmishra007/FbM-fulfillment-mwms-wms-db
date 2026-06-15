SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Stored Procedure: isp_RCM_MB_LVSUSA_Scan2DoorCut                     */
/* Creation Date: 2026-05-06                                            */
/* Copyright: MAERSK Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: FCR-13547 - LVSUSA_Scan_to_door_cutting_process             */
/*                                                                      */
/* Called By: MBOL Dymaic RCM configure at listname 'RCMConfig'         */
/*                                                                      */
/* Parameters:                                                          */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver.  Purposes                                  */
/* 2026-04-27  Wan      1.0   DevOps Combine Script                     */
/************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[isp_RCM_MB_LVSUSA_Scan2DoorCut]
   @c_Mbolkey     NVARCHAR(10)
,  @b_Success     INT            = 1    OUTPUT
,  @n_Err         INT            = 0    OUTPUT
,  @c_Errmsg      NVARCHAR(225)  = ''   OUTPUT
,  @c_code        NVARCHAR(30)   = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF    
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue           INT   = 1
         , @n_Cnt                INT   = 0
         , @n_Starttcnt          INT   = @@TRANCOUNT

         , @c_UserName           NVARCHAR(128)  = ''
         , @c_Facility           NVARCHAR(5)    = ''
         , @c_Orderkey           NVARCHAR(10)   = ''
         , @c_PickDetailKey      NVARCHAR(10)   = ''
         , @c_CaseID             NVARCHAR(20)   = ''
         , @c_CaseID_P           NVARCHAR(20)   = ''         
         , @c_Storerkey          NVARCHAR(15)   = ''
         , @c_Sku                NVARCHAR(20)   = ''
         , @c_Lot                NVARCHAR(10)   = ''  
         , @c_Loc                NVARCHAR(10)   = ''  
         , @c_ID                 NVARCHAR(18)   = '' 
         , @c_Palletkey          NVARCHAR(30)   = '' 
         , @c_PalletLineNumber   NVARCHAR(5)    = ''
         , @c_CutCode            NCHAR(5)       = ''
         , @c_CutCode_P          NCHAR(5)       = ''
         , @c_Move               NCHAR(5)       = ''
         , @c_MoveToLoc          NVARCHAR(10)   = ''
         , @c_PickSlipNo         NVARCHAR(10)   = ''
         , @c_LabelLine          NVARCHAR(5)    = ''
         , @c_Packkey            NVARCHAR(10)   = ''
         , @c_PackUOM3           NVARCHAR(10)   = ''
         , @n_CartonNo           INT            = 0
         , @n_Qty                INT            = 0
         , @n_QtyPack            INT            = 0
         , @n_QtyLeftToFulfill   INT            = 0
         
         , @c_SourceType         NVARCHAR(30)   = 'isp_RCM_MB_LVSUSA_Scan2DoorCut'
         
         , @cur_CS               CURSOR
         , @cur_PACK             CURSOR
         , @cur_PLD              CURSOR
  
   SET @b_Success = 1
   SET @c_Errmsg  = ''
   SET @n_Err     = 0
   SET @c_UserName= dbo.fnc_GetUserName()

   IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_ORD
   END

   CREATE TABLE #TMP_ORD
   (  [Orderkey]                    [nvarchar](10)    NOT NULL    PRIMARY KEY 
   ,  [Parcel]                      [bit]             NOT NULL    DEFAULT(0) 
   ) 

   IF OBJECT_ID('tempdb..#TMP_ORDCS') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_ORDCS
   END

   CREATE TABLE #TMP_ORDCS
   (  [RowID]                       [int]             IDENTITY(1,1)  PRIMARY KEY
   ,  [CaseID]                      [nvarchar](20)    NOT NULL    DEFAULT('') 
   ,  [Storerkey]                   [nvarchar](15)    NOT NULL    DEFAULT('')  
   ) 

   IF OBJECT_ID('tempdb..#TMP_CS') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_CS
   END

   CREATE TABLE #TMP_CS
   (  [RowID]                       [int]             IDENTITY(1,1)  PRIMARY KEY
   ,  [Orderkey]                    [nvarchar](10)    NOT NULL    DEFAULT('')
   ,  [PickDetailKey]               [nvarchar](10)    NOT NULL    DEFAULT('')
   ,  [CaseID]                      [nvarchar](20)    NOT NULL    DEFAULT('') 
   ,  [Storerkey]                   [nvarchar](15)    NOT NULL    DEFAULT('')  
   ,  [Sku]                         [nvarchar](20)    NOT NULL    DEFAULT('')
   ,  [Lot]                         [nvarchar](10)    NOT NULL    DEFAULT('')  
   ,  [Loc]                         [nvarchar](10)    NOT NULL    DEFAULT('')  
   ,  [ID]                          [nvarchar](18)    NOT NULL    DEFAULT('') 
   ,  [Qty]                         [int]             NOT NULL    DEFAULT(0)
   ,  [Palletkey]                   [nvarchar](30)    NOT NULL    DEFAULT('')  
   ) 
   
   IF OBJECT_ID('tempdb..#TMP_CL') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_CL
   END

   CREATE TABLE #TMP_CL
   (  [RowID]                       INT               IDENTITY(1,1) PRIMARY KEY                   
   ,  [LISTNAME]                    [nvarchar](10)    NULL     
   ,  [Code]                        [nvarchar](30)    NULL  
   ,  [Description]                 [nvarchar](250)   NULL  
   ,  [Short]                       [nvarchar](10)    NULL  
   ,  [Long]                        [nvarchar](250)   NULL  
   ,  [Notes]                       [nvarchar](4000)  NULL  
   ,  [Notes2]                      [nvarchar](4000)  NULL  
   ,  [Storerkey]                   [nvarchar](50)    NOT NULL  
   ,  [UDF01]                       [nvarchar](60)    NOT NULL  
   ,  [UDF02]                       [nvarchar](60)    NOT NULL  
   ,  [UDF03]                       [nvarchar](60)    NOT NULL  
   ,  [UDF04]                       [nvarchar](60)    NOT NULL  
   ,  [UDF05]                       [nvarchar](60)    NOT NULL  
   ,  [Code2]                       [nvarchar](30)    NOT NULL 
   ) 

   INSERT INTO #TMP_ORD ( Orderkey, Parcel )
   SELECT DISTINCT 
          o.OrderKey
         ,Parcel = CASE WHEN cl.ListName IS NULL THEN 0 ELSE 1 END   
   FROM MBOLDETAIL md (NOLOCK) 
   JOIN ORDERS o (NOLOCK) ON o.Orderkey = md.Orderkey
   LEFT OUTER JOIN CODELKUP CL (NOLOCK) ON  CL.Listname = 'WSCOURIER'
                                        AND CL.Code = 'ECL-1'
                                        AND CL.StorerKey = o.Storerkey
                                        AND CL.Short= o.ShipperKey
   WHERE md.MbolKey = @c_Mbolkey 

   IF EXISTS ( SELECT 1 FROM #TMP_ORD WHERE Parcel = 1) 
   BEGIN
      SET @n_Continue = 3
      SET @n_Err      = 70010
      SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                      + ': Parcel order is not allowed'
                      + '. (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
   END

   IF @n_Continue = 1
   BEGIN
      INSERT INTO #TMP_ORDCS ( CaseID, Storerkey )  
      SELECT DISTINCT   
             pd.CaseID 
            ,pd.Storerkey
      FROM #TMP_ORD o
      JOIN PICKDETAIL pd (NOLOCK) ON pd.Orderkey  = o.Orderkey
      WHERE o.Parcel = 0
      AND   pd.[Status] = '5'
      AND   pd.CaseID   <> ''   
      
      INSERT INTO #TMP_CS ( Orderkey, PickDetailKey, CaseID
                          , Storerkey, Sku, Lot, Loc, ID, Qty
                          )
      SELECT DISTINCT 
             pd.Orderkey
            ,pd.PickDetailKey
            ,pd.CaseId
            ,pd.Storerkey
            ,pd.Sku
            ,pd.Lot
            ,pd.Loc
            ,pd.ID
            ,pd.Qty
      FROM #TMP_ORDCS oc
      JOIN PICKDETAIL pd (NOLOCK) ON  pd.CaseID  = oc.CaseID
                                  AND pd.Storerkey = oc.Storerkey
      WHERE pd.[Status] = '5'
      AND NOT EXISTS (SELECT 1 FROM PALLETDETAIL pld (NOLOCK) 
                      WHERE pld.StorerKey = pd.Storerkey
                      AND   pld.CaseId    = pd.CaseID
                      AND   pld.[Status]  ='9'
                     )
      ORDER BY pd.CaseID
             , pd.OrderKey

      SET @n_Cnt = @@ROWCOUNT

      IF @n_Cnt = 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err      = 70020
         SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                         + ': Nothing To Cut'
                         + '. (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
      END

      IF @n_Continue = 1
      BEGIN
         UPDATE cs
            SET cs.Palletkey = pld.PalletKey
         FROM #TMP_CS AS cs
         JOIN PALLETDETAIL pld (NOLOCK) 
                      ON   pld.StorerKey = cs.Storerkey
                      AND  pld.CaseId    = cs.CaseID
         WHERE pld.[Status] < '9'
      END
   END

   IF @n_Continue = 1
   BEGIN
      SELECT @c_Facility = m.Facility
      FROM MBOL m (NOLOCK)
      WHERE m.MbolKey = @c_Mbolkey

      INSERT INTO #TMP_CL( Listname, Code, Description, Short, Long                
                        ,  Notes, Notes2, Storerkey
                        ,  UDF01, UDF02, UDF03, UDF04, UDF05, Code2
                        )  
      SELECT CL.Listname   
            , CL.Code   
            , [Description] = ISNULL(CL.[Description],'')   
            , Short = ISNULL(CL.Short,'')      
            , Long  = ISNULL(CL.Long ,'')     
            , Notes = ISNULL(CL.Notes,'')      
            , Notes2= ISNULL(CL.Notes2,'')           
            , CL.Storerkey  
            , CL.UDF01   
            , CL.UDF02   
            , CL.UDF03   
            , CL.UDF04   
            , CL.UDF05   
            , CL.Code2  
      FROM CODELKUP CL (NOLOCK)  
      WHERE CL.Listname = 'LVSCUT'

      IF EXISTS ( SELECT 1 FROM #TMP_CS cs 
                  WHERE cs.PalletKey > ''
                  AND NOT EXISTS (  SELECT 1
                                    FROM #TMP_CL CL  
                                    JOIN LOC l (NOLOCK) ON l.Loc = cl.Short
                                    WHERE CL.Listname = 'LVSCUT'
                                    AND   CL.Code = 'P'
                                    AND   CL.Storerkey  = cs.Storerkey                                    
                                    AND   l.Facility = @c_Facility
                                 )
                ) 
      BEGIN
         SET @n_Continue = 3
         SET @n_Err      = 70030
         SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                         + ': Virtual Location not set up for Pallet moves'
                         + '. (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
      END

      IF @n_Continue = 1
      BEGIN
         IF EXISTS ( SELECT 1 FROM #TMP_CS cs 
                     WHERE cs.PalletKey = ''
                     AND NOT EXISTS (  SELECT 1
                                       FROM #TMP_CL CL    
                                       JOIN LOC l (NOLOCK) ON l.Loc = cl.Short
                                       WHERE CL.Listname = 'LVSCUT'
                                       AND   CL.Code = 'C'
                                       AND   CL.Storerkey  = cs.Storerkey
                                       AND   l.Facility = @c_Facility
                                    )
                  ) 
         BEGIN
            SET @n_Continue = 3
            SET @n_Err      = 70040
            SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                            + ': Virtual Location not set up for Carton moves'
                            + '. (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
         END
      END
   END

   IF @n_Continue = 1
   BEGIN
      SET @cur_CS = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT cs.Orderkey
            ,cs.PickDetailKey
            ,cs.CaseId
            ,cs.Storerkey
            ,cs.Sku
            ,cs.Lot
            ,cs.Loc
            ,cs.ID
            ,cs.Qty
            ,cs.PalletKey
      FROM #TMP_CS cs
      ORDER BY cs.PalletKey
             , cs.CaseId 
             , cs.Orderkey

      OPEN @cur_CS

      FETCH NEXT FROM @cur_CS INTO @c_Orderkey
                                 , @c_PickDetailKey
                                 , @c_CaseID
                                 , @c_Storerkey
                                 , @c_Sku
                                 , @c_Lot
                                 , @c_Loc
                                 , @c_ID
                                 , @n_Qty
                                 , @c_PalletKey

      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         SET @c_CutCode = 'P'
         IF @c_Palletkey = ''
         BEGIN
            SET @c_CutCode = 'C'
         END

         IF @c_CutCode_P <> @c_CutCode
         BEGIN
            SET @c_CutCode_P = @c_CutCode

            SET @c_MoveToLoc = ''
            SET @c_Move      = ''
            SELECT @c_MoveToLoc = cl.Short
                 , @c_Move      = cl.UDF01
            FROM #TMP_CL cl
            WHERE cl.LISTNAME = 'LVSCut'
            AND cl.Code = @c_CutCode
         END

         SET @n_QtyLeftTofulfill = @n_Qty
         --UnPack
         SET @cur_PACK = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT pd.PickSlipNo
              , pd.CartonNo
              , pd.LabelLine
              , pd.Qty
         FROM PACKDETAIL pd (NOLOCK)
         JOIN PACKHEADER ph (NOLOCK) ON ph.PickSlipNo = pd.PickSlipNo
         WHERE pd.LabelNo = @c_CaseID
         AND   pd.Sku     = @c_Sku
         AND   ph.Orderkey= @c_Orderkey

         OPEN @cur_PACK

         FETCH NEXT FROM @cur_PACK INTO   @c_PickSlipNo
                                       ,  @n_CartonNo
                                       ,  @c_LabelLine
                                       ,  @n_QtyPack

         WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1 AND @n_QtyLeftTofulfill > 0
         BEGIN
            IF @n_QtyPack > @n_Qty
            BEGIN
               SET @n_QtyPack = @n_Qty

               UPDATE pd
                  SET Qty = Qty - @n_QtyPack
               FROM PACKDETAIL AS pd
               WHERE pd.PickSlipNo = @c_PickSlipNo
               AND pd.CartonNo = @n_CartonNo
               AND pd.LabelNo  = @c_CaseID
               AND pd.LabelLine= @c_LabelLine

               SET @n_Err = @@ERROR

               IF @n_Err > 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err      = 70050
                  SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                                    + ': Error on Update Packdetail'
                                    + '. (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
               END
            END
            ELSE
            BEGIN
               DELETE pd
               FROM PACKDETAIL AS pd
               WHERE pd.PickSlipNo = @c_PickSlipNo
               AND pd.CartonNo = @n_CartonNo
               AND pd.LabelNo  = @c_CaseID
               AND pd.LabelLine= @c_LabelLine

               SET @n_Err = @@ERROR

               IF @n_Err > 0
               BEGIN
                  SET @n_Continue = 3
                  SET @n_Err      = 70060
                  SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                                    + ': Error on Delete Packdetail'
                                    + '. (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
               END
            END
            SET @n_QtyLeftTofulfill = @n_QtyLeftTofulfill - @n_QtyPack

            IF @n_Continue = 1
            BEGIN
               IF NOT EXISTS (SELECT 1
                              FROM PACKDETAIL pd (NOLOCK)
                              WHERE pd.PickSlipNo = @c_PickSlipNo
                              )
               BEGIN
                  DELETE FROM pd
                  FROM PACKHEADER AS pd
                  WHERE pd.PickSlipNo = @c_PickSlipNo

                  SET @n_Err = @@ERROR

                  IF @n_Err > 0
                  BEGIN
                     SET @n_Continue = 3
                     SET @n_Err      = 70070
                     SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                                       + ': Error on Delete PackHeader'
                                       + '. (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
                  END
               END
            END
               
            FETCH NEXT FROM @cur_PACK INTO   @c_PickSlipNo
                                          ,  @n_CartonNo
                                          ,  @c_LabelLine
                                          ,  @n_QtyPack
         END
         CLOSE @cur_PACK
         DEALLOCATE @cur_PACK
         
         IF @n_Continue = 1
         BEGIN
            UPDATE pd WITH (ROWLOCK)
               SET pd.Qty = 0
                  ,pd.[Status] = '0'
                  ,pd.MoveRefKey = CASE WHEN @c_Move = '1' THEN pd.PickDetailKey ELSE '' END
            FROM PICKDETAIL AS pd
            WHERE pd.PickDetailKey = @c_PickDetailKey

            SET @n_Err = @@ERROR

            IF @n_Err > 0
            BEGIN
               SET @n_Continue = 3
               SET @n_Err      = 70080
               SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                                 + ': Error on Update Pickdetail'
                                 + '. (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
            END
         END

         IF @n_Continue = 1 AND @c_Move = '1'
         BEGIN
            SELECT @c_Packkey = p.Packkey
                  ,@c_PackUOM3= p.PackUOM3
            FROM SKU s (NOLOCK)
            JOIN PACK p (NOLOCK) ON p.Packkey = s.Packkey
            WHERE s.StorerKey = @c_Storerkey
            AND   s.Sku = @c_Sku

            EXEC [dbo].[nspItrnAddMove]  
               @n_ItrnSysId    = NULL  
            ,  @c_StorerKey    = @c_Storerkey
            ,  @c_Sku          = @c_Sku
            ,  @c_Lot          = @c_Lot
            ,  @c_FromLoc      = @c_Loc 
            ,  @c_FromID       = @c_ID
            ,  @c_ToLoc        = @c_MoveToLoc   
            ,  @c_ToID         = @c_ID
            ,  @c_Status       = '' 
            ,  @c_lottable01   = '' 
            ,  @c_lottable02   = '' 
            ,  @c_lottable03   = '' 
            ,  @d_lottable04   = ''
            ,  @d_lottable05   = ''
            ,  @c_lottable06   = ''    
            ,  @c_lottable07   = ''    
            ,  @c_lottable08   = ''    
            ,  @c_lottable09   = ''    
            ,  @c_lottable10   = ''    
            ,  @c_lottable11   = ''    
            ,  @c_lottable12   = ''    
            ,  @d_lottable13   = NULL  
            ,  @d_lottable14   = NULL  
            ,  @d_lottable15   = NULL  
            ,  @n_casecnt      = 0
            ,  @n_innerpack    = 0
            ,  @n_qty          = @n_Qty
            ,  @n_pallet       = 0
            ,  @f_cube         = 0 
            ,  @f_grosswgt     = 0 
            ,  @f_netwgt       = 0 
            ,  @f_otherunit1   = 0 
            ,  @f_otherunit2   = 0 
            ,  @c_SourceKey    = ''
            ,  @c_SourceType   = @c_SourceType 
            ,  @c_PackKey      = @c_Packkey 
            ,  @c_UOM          = @c_PackUOM3 
            ,  @b_UOMCalc      = 0  
            ,  @d_EffectiveDate= NULL
            ,  @c_itrnkey      = '' 
            ,  @b_Success      = @b_Success  OUTPUT  
            ,  @n_err          = @n_Err      OUTPUT  
            ,  @c_errmsg       = @c_Errmsg   OUTPUT  
            ,  @c_MoveRefKey   = @c_PickDetailKey      
            ,  @c_Channel      = ''       
            ,  @n_Channel_ID   = 0  

            IF @n_Err > 0
            BEGIN
               SET @n_Continue = 3
               SET @n_Err      = 70090
               SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                                 + ': Error EXEC nspItrnAddMove'
                                 + '. (' + @c_Errmsg + ')'
                                 + ' (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
            END

            IF @n_Continue = 1 AND @c_Palletkey > '' AND @c_CaseID <> @c_CaseID_P
            BEGIN 
               SET @cur_PLD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT pld.PalletLineNumber
               FROM PALLETDETAIL pld (NOLOCK)
               WHERE pld.Storerkey= @c_Storerkey
               AND   pld.CaseID = @c_CaseID
               AND   pld.Loc    = @c_Loc
               AND   pld.PalletKey = @c_Palletkey
               AND   pld.[Status]  < '9'

               OPEN @cur_PLD

               FETCH NEXT FROM @cur_PLD INTO @c_PalletLineNumber

               WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1 
               BEGIN
                  UPDATE pld WITH (ROWLOCK)
                     SET pld.Loc = @c_MoveToLoc
                        ,pld.EditDate = GETDATE()
                        ,pld.EditWho = @c_UserName
                        ,pld.TrafficCop = NULL
                  FROM PALLETDETAIL AS pld
                  WHERE pld.PalletKey = @c_Palletkey
                  AND   pld.PalletLineNumber = @c_PalletLineNumber

                  SET @n_Err = @@ERROR
                  IF @n_Err > 0
                  BEGIN
                     SET @n_Continue = 3
                     SET @n_Err      = 70100
                     SET @c_Errmsg   = 'NSQL' + CONVERT(NVARCHAR(5),@n_Err)
                                     + ': Error Update Palletdetail'
                                     + '. (isp_RCM_MB_LVSUSA_Scan2DoorCut)'
                  END

                  FETCH NEXT FROM @cur_PLD INTO @c_PalletLineNumber
               END
               CLOSE @cur_PLD
               DEALLOCATE @cur_PLD
            END
         END

         SET @c_CaseID_P = @c_CaseID

         FETCH NEXT FROM @cur_CS INTO @c_Orderkey
                                    , @c_PickDetailKey
                                    , @c_CaseID
                                    , @c_Storerkey
                                    , @c_Sku
                                    , @c_Lot
                                    , @c_Loc
                                    , @c_ID
                                    , @n_Qty
                                    , @c_PalletKey
      END
      CLOSE @cur_CS
      DEALLOCATE @cur_CS
   END

   QUIT_SP:
   
   IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_ORD
   END

   IF OBJECT_ID('tempdb..#TMP_ORDCS') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_ORDCS
   END

   IF OBJECT_ID('tempdb..#TMP_CS') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_CS
   END
   
   IF OBJECT_ID('tempdb..#TMP_CL') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_CL
   END
  
   IF @n_Continue = 3 -- Error Occured - Process And Return  
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_Starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_Starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_Err, @c_Errmsg, 'isp_RCM_MB_LVSUSA_Scan2DoorCut'
      RAISERROR(@c_Errmsg, 16, 1) WITH SETERROR -- SQL2012 
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_Starttcnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- End PROC  
GO
GRANT EXECUTE ON [dbo].[isp_RCM_MB_LVSUSA_Scan2DoorCut] TO [NSQL]
GO