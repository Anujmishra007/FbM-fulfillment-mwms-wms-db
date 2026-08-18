SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*************************************************************************/    
/* Stored Procedure: mspRLWAV06                                          */    
/* Creation Date: 2025-03-19                                             */
/* Copyright: Maersk Logistics                                           */    
/* Written by: Wan                                                       */      
/*                                                                       */    
/* Purpose: UWP-31639 - [FCR-3286] Generate replenishment from wave release*/  
/*                                                                       */  
/*                                                                       */    
/* Called By: Wave Release                                               */    
/*                                                                       */    
/* PVCS Version: 1.0                                                     */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/*24-Jun-2026  AndyWu01 1.1   bug fix for  UWP-59134                     */
/*************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV06]
  @c_Wavekey      NVARCHAR(10)
 ,@b_Success      int            = 1   OUTPUT
 ,@n_Err          int            = 0   OUTPUT
 ,@c_Errmsg       NVARCHAR(250)  = ''  OUTPUT
 AS
 BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue                 INT = 1
         , @n_starttcnt                INT = @@TRANCOUNT         -- Holds the current transaction count
         , @n_debug                    INT = 0
         , @n_cnt                      INT = 0

   DECLARE @n_UCC_RowRef               INT            = 0
         , @c_Storerkey                NVARCHAR(15)   = ''
         , @c_Facility                 NVARCHAR(5)    = ''
         , @c_Orderkey                 NVARCHAR(10)   = ''

         , @c_Replenishmentkey         NVARCHAR(10)   = ''
         , @c_ReplenishmentGroup       NVARCHAR(30)   = 'mspRLWAV06'
         , @c_Sku                      NVARCHAR(20)   = ''
         , @c_Lot                      NVARCHAR(10)   = ''
         , @c_FromLoc                  NVARCHAR(10)   = ''
         , @c_FromID                   NVARCHAR(18)   = ''
         , @c_Toloc                    NVARCHAR(10)   = ''
         , @c_ToID                     NVARCHAR(18)   = ''
         , @c_UCCNo                    NVARCHAR(20)   = ''
         , @n_Qty                      INT            = 0
         , @n_UOMQty                   INT            = 0
         , @c_Packkey                  NVARCHAR(10)   = ''
         , @c_UOM                      NVARCHAR(10)   = ''
         , @c_SQL                      NVARCHAR(MAX)  = ''            
         , @c_SQLParams                NVARCHAR(2000) = ''               

         , @CUR_RPL                    CURSOR
 
   -----Get Storerkey and facility
   SELECT TOP 1 @c_StorerKey = O.Storerkey,
               @c_Facility = O.Facility
   FROM WAVE W (NOLOCK)
   JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
   JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
   WHERE WD.Wavekey = @c_Wavekey

   ------Loadplan Validation
   IF  (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      IF EXISTS (
                  SELECT TOP 1 O.Orderkey
                  FROM WAVE W (NOLOCK)
                  JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
                  JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                  LEFT OUTER JOIN LOADPLANDETAIL lpd (NOLOCK) ON lpd.Orderkey = O.Orderkey
                  WHERE W.Wavekey = @c_Wavekey
                  AND lpd.Loadkey IS NULL
                )
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 83010
         SET @c_Errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)+': Loadplan has not generated yet. (mspRLWAV06)'
      END
   END
   
   IF @@TRANCOUNT = 0
      BEGIN TRAN

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF EXISTS ( SELECT 1 FROM REPLENISHMENT rpl (NOLOCK)
                  WHERE rpl.Wavekey = @c_Wavekey
                )
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 83010
         SET @c_Errmsg = 'NSQL' + CONVERT(NCHAR(5), @n_Err) 
                       + ': Replenishment has been created. (mspRLWAV06)'
      END
   END

   IF @n_Continue IN(1,2)
   BEGIN
      SET @CUR_RPL = CURSOR LOCAL FAST_FORWARD READ_ONLY  FOR
      SELECT pd.Storerkey
            ,pd.Sku
            ,pd.Lot
            ,pd.loc
            ,pd.ID
            ,TdoLoc = ISNULL(cl.Short,'') 
            ,pd.DropID
            ,p.PackKey
            --,p.PackUOM1 --AndyWu01
			,p.PackUOM3
            ,UCC.UCC_RowRef
            ,Qty = UCC.Qty
      FROM PICKDETAIL pd (NOLOCK)
      JOIN WAVEDETAIL wd (NOLOCK) ON wd.Orderkey = pd.Orderkey
      JOIN LOC l (NOLOCK) ON l.Loc = pd.Loc
      JOIN UCC (NOLOCK) ON UCC.Storerkey = pd.Storerkey
                        AND UCC.UCCNo = pd.DropID
                        AND UCC.[Status] = '3'
      JOIN SKU (NOLOCK) ON  SKU.Storerkey = pd.Storerkey
                        AND SKU.Sku = pd.Sku
      JOIN PACK p (NOLOCK) ON p.Packkey = SKU.Packkey
      JOIN CODELKUP cl (NOLOCK) ON cl.Code = SKU.SkuGroup
      WHERE wd.WaveKey = @c_Wavekey
      AND   pd.[Status] = '0'
      AND   pd.UOM = '6'
      AND   pd.DropID > ''
      AND   l.LocationType IN ('OTHER')
      AND   cl.LISTNAME = 'PUMAREP'
      GROUP BY pd.Storerkey
            ,  pd.Sku
            ,  pd.Lot
            ,  pd.loc
            ,  pd.ID
            ,  pd.DropID
            ,  pd.UOM 
            ,  p.PackKey
            --,p.PackUOM1 --AndyWu01
			,  p.PackUOM3
            ,  UCC.UCC_RowRef
            ,  UCC.Qty
            ,  ISNULL(cl.Short,'') 
      ORDER BY pd.UOM 
            ,  MIN(pd.PickDetailKey)
    
      OPEN @CUR_RPL

      FETCH NEXT FROM @CUR_RPL INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID, @c_ToLoc, @c_UCCNo
                                    ,  @c_Packkey, @c_UOM, @n_UCC_RowRef, @n_Qty

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
      BEGIN
         IF @c_ToLoc = ''
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 83020
            SET @c_Errmsg = 'NSQL' + CONVERT(NCHAR(5), @n_Err) 
                          + ': ToLoc is required for replenishment. (mspRLWAV06)'
         END

         IF @n_Continue IN (1,2) 
         BEGIN
            SET @c_ToID = @c_FromID

            SELECT @c_ToID = ''
            FROM LOC WITH (NOLOCK)
            WHERE Loc = @c_Toloc
            AND loseID = 1

            EXECUTE nspg_GetKey     
               @keyname     = 'REPLENISHMENT'      
             , @fieldlength = 10      
             , @keystring   = @c_ReplenishmentKey  OUTPUT     
             , @b_success   = @b_Success           OUTPUT     
             , @n_err       = @n_Err               OUTPUT     
             , @c_errmsg    = @c_ErrMsg            OUTPUT      
             
            IF @b_Success = 0    
            BEGIN    
               SET @n_Continue = 3    
            END  
         END

         IF @n_Continue IN (1,2) 
         BEGIN
            INSERT INTO REPLENISHMENT ( ReplenishmentKey, ReplenishmentGroup, Storerkey, Sku
                                      , PackKey, UOM
                                      , Lot, FromLoc, ID, ToLoc, toID, Wavekey, RefNo
                                      , Qty, QtyReplen, Confirmed
                                      )
            VALUES ( @c_ReplenishmentKey, @c_ReplenishmentGroup, @c_Storerkey, @c_Sku
                   , @c_Packkey, @c_UOM
                   , @c_Lot, @c_FromLoc, @c_FromID, @c_ToLoc, @c_Toid, @c_Wavekey, @c_UCCNo
                   , @n_Qty, @n_Qty, 'N'
                   ) 

            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3
            END
         END
  
         IF @n_Continue IN (1,2) 
         BEGIN
            UPDATE UCC WITH (ROWLOCK)
               SET [Status] = '4'
            WHERE UCC_RowRef = @n_UCC_RowRef

            IF @@ERROR <> 0
            BEGIN
               SET @n_Continue = 3
            END
         END
 
         FETCH NEXT FROM @CUR_RPL INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID, @c_ToLoc, @c_UCCNo
                                       ,  @c_Packkey, @c_UOM, @n_UCC_RowRef, @n_Qty
      END
      CLOSE @CUR_RPL
      DEALLOCATE @CUR_RPL
   END

QUIT_SP:
 
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      execute nsp_logerror @n_Err, @c_Errmsg, 'mspRLWAV06'
      RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
   END
END
GO
GRANT EXECUTE ON [dbo].[mspRLWAV06] TO [NSQL]
GO