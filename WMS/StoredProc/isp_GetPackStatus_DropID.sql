IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetPackStatus_DropID]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetPackStatus_DropID]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_GetPackStatus_DropID                                */
/* Creation Date: 05-APR-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: WAN                                                      */
/*                                                                      */
/* Purpose: WMS-1466 - CN & SG Logitech - Packing                       */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 16-JUN-2017 Wan01    1.1   WMS-1466 - Use refno2 to get qtypacked    */
/* 30-Aug-2017 TLTING   1.2   Performance tune                          */
/************************************************************************/
CREATE PROC [dbo].[isp_GetPackStatus_DropID] 
       @c_DropID  NVARCHAR(20)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT
         
         , @c_Wavekey         NVARCHAR(10)

         --(Wan01) - START
         , @b_Success         INT               
         , @n_err             INT
         , @c_ErrMsg          NVARCHAR(255) 
         , @c_StorerKey                NVARCHAR(15)
         , @c_PACKToteSumQtyByRefNo2   NVARCHAR(30)
         --(Wan01) - END

   SET @n_StartTCnt = @@TRANCOUNT

   WHILE @@TRANCOUNT > 0 
   BEGIN
      COMMIT TRAN
   END;

   SET @c_Wavekey = ''
   IF @c_DropID <> ''
   BEGIN
      SELECT TOP 1 @c_Wavekey  = Wavekey
               ,  @c_StorerKey = Storerkey            --(Wan01)
      FROM dbo.fnc_GetWaveOrder_DropID(@c_DropID);
      
      --(Wan01) - START
      SET @c_PACKToteSumQtyByRefNo2 = ''
      EXEC nspGetRight      
         @c_Facility  = NULL      
      ,  @c_StorerKey = @c_StorerKey      
      ,  @c_sku       = NULL      
      ,  @c_ConfigKey = 'PACKToteSumQtyByRefNo2'      
      ,  @b_Success   = @b_Success                 OUTPUT      
      ,  @c_authority = @c_PACKToteSumQtyByRefNo2  OUTPUT      
      ,  @n_err       = @n_err                     OUTPUT      
      ,  @c_errmsg    = @c_errmsg                  OUTPUT  
      --(Wan01) - END                
   END;


   IF @c_PACKToteSumQtyByRefNo2 =  '1'
   BEGIN

      WITH 
      PICK_ORD( Storerkey, Sku, QtyAllocated)
      AS (  SELECT PD.Storerkey
                  ,PD.Sku
                  ,QtyAllocated = ISNULL(SUM(PD.Qty),0)
            FROM PICKDETAIL PD WITH (NOLOCK)
            JOIN WAVEDETAIL WD WITH (NOLOCK) ON (PD.Orderkey = WD.Orderkey)
            WHERE PD.DropID = @c_DropID
            AND   WD.Wavekey= @c_Wavekey
            AND @c_DropID <> ''
            GROUP BY PD.Storerkey
                  ,  PD.Sku
         )
      ,
         PACK_ORD( Storerkey, Sku, QtyPacked)
         AS (  SELECT PD.Storerkey
                     ,PD.Sku
                     ,QtyPacked = ISNULL(SUM(PD.Qty),0)
               FROM PACKDETAIL PD WITH (NOLOCK) 
               JOIN PACKHEADER PH WITH (NOLOCK) ON (PD.PickSlipNo = PH.PickSlipNo)
               JOIN WAVEDETAIL WD WITH (NOLOCK) ON (PH.Orderkey = WD.Orderkey)
               WHERE  ( PD.RefNo2 = @c_DropID   )  -- AND @c_PACKToteSumQtyByRefNo2 =  '1'
               AND   WD.Wavekey= @c_Wavekey
               AND   @c_DropID <> ''
               GROUP BY PD.Storerkey
                     ,  PD.Sku          
            )

      SELECT PICK_ORD.Storerkey
            ,PICK_ORD.Sku
            ,QtyAllocated = PICK_ORD.QtyAllocated
            ,QtyPacked    = ISNULL(PACK_ORD.QtyPacked,0)
            ,BalQty       = PICK_ORD.QtyAllocated - ISNULL(PACK_ORD.QtyPacked,0)
		      ,'    ' rowfocusindicatorcol    
      FROM PICK_ORD
      LEFT JOIN PACK_ORD ON  (PICK_ORD.Storerkey = PACK_ORD.Storerkey)
                         AND (PICK_ORD.Sku = PACK_ORD.Sku)
      ORDER BY PICK_ORD.Sku
      

   END
   ELSE
   BEGIN

      WITH 
      PICK_ORD( Storerkey, Sku, QtyAllocated)
      AS (  SELECT PD.Storerkey
                  ,PD.Sku
                  ,QtyAllocated = ISNULL(SUM(PD.Qty),0)
            FROM PICKDETAIL PD WITH (NOLOCK)
            JOIN WAVEDETAIL WD WITH (NOLOCK) ON (PD.Orderkey = WD.Orderkey)
            WHERE PD.DropID = @c_DropID
            AND   WD.Wavekey= @c_Wavekey
            AND @c_DropID <> ''
            GROUP BY PD.Storerkey
                  ,  PD.Sku
         )
      ,
         PACK_ORD( Storerkey, Sku, QtyPacked)
         AS (  SELECT PD.Storerkey
                     ,PD.Sku
                     ,QtyPacked = ISNULL(SUM(PD.Qty),0)
               FROM PACKDETAIL PD WITH (NOLOCK) 
               JOIN PACKHEADER PH WITH (NOLOCK) ON (PD.PickSlipNo = PH.PickSlipNo)
               JOIN WAVEDETAIL WD WITH (NOLOCK) ON (PH.Orderkey = WD.Orderkey)
               WHERE ( PD.DropID = @c_DropID  )    -- AND @c_PACKToteSumQtyByRefNo2 <> '1'
               AND   WD.Wavekey= @c_Wavekey
               AND   @c_DropID <> ''
               GROUP BY PD.Storerkey
                     ,  PD.Sku          
            )

      SELECT PICK_ORD.Storerkey
            ,PICK_ORD.Sku
            ,QtyAllocated = PICK_ORD.QtyAllocated
            ,QtyPacked    = ISNULL(PACK_ORD.QtyPacked,0)
            ,BalQty       = PICK_ORD.QtyAllocated - ISNULL(PACK_ORD.QtyPacked,0)
		      ,'    ' rowfocusindicatorcol    
      FROM PICK_ORD
      LEFT JOIN PACK_ORD ON  (PICK_ORD.Storerkey = PACK_ORD.Storerkey)
                         AND (PICK_ORD.Sku = PACK_ORD.Sku)
      ORDER BY PICK_ORD.Sku

   END

    

QUIT_SP:

   WHILE @@TRANCOUNT < @n_StartTCnt 
   BEGIN
      BEGIN TRAN
   END

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetPackStatus_DropID] TO nSQL 
GO