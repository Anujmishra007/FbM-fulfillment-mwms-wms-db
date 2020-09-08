IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispPAKCF12]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispPAKCF12]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: ispPAKCF12                                            */
/* Creation Date: 27-Jun-2019                                              */
/* Copyright: LFL                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: WMS-15009 CN Natural Beauty pack confirm update serial no      */
/*                                                                         */
/* Called By: PostPackConfirmSP                                            */
/*                                                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author  Ver   Purposes                                     */
/***************************************************************************/  
CREATE PROC [dbo].[ispPAKCF12]  
(     @c_PickSlipNo  NVARCHAR(10)   
  ,   @c_Storerkey   NVARCHAR(15)
  ,   @b_Success     INT           OUTPUT
  ,   @n_Err         INT           OUTPUT
  ,   @c_ErrMsg      NVARCHAR(255) OUTPUT   
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @b_Debug           INT
         , @n_Continue        INT 
         , @n_StartTCnt       INT 
 
   DECLARE @C_Orderkey        NVARCHAR(10)
         , @c_OrderLineNumber NVARCHAR(5)
         , @c_Sku             NVARCHAR(20)
         --, @c_Lot             NVARCHAR(10)
         --, @c_ID              NVARCHAR(18)
         , @n_Qty             INT
         , @c_SerialNoKey     NVARCHAR(10)
         , @c_SQL             NVARCHAR(MAX)
         , @c_Orderkey1sttime NVARCHAR(10)
         , @c_DropID          NVARCHAR(20)
         , @n_CartonNo        INT
         , @c_LabelLine       NVARCHAR(5)
   
   SET @b_Success= 1 
   SET @n_Err    = 0  
   SET @c_ErrMsg = ''
   SET @b_Debug  = 0 
   SET @n_Continue = 1  
   SET @n_StartTCnt = @@TRANCOUNT  
  
   IF @@TRANCOUNT = 0
      BEGIN TRAN
      	

   SELECT PD.Storerkey, PD.Sku, PD.DropID, MAX(PD.CartonNo) AS CartonNo, MAX(PD.LabelLine) AS LabelLine     
   INTO #TMP_DROPID
   FROM PACKHEADER PH (NOLOCK) 
   JOIN PACKDETAIL PD (NOLOCK) ON PH.Pickslipno = PD.Pickslipno
   WHERE PH.PickslipNo = @c_Pickslipno
   AND ISNULL(PD.DropID,'') <> ''
   GROUP BY PD.Storerkey, PD.Sku, PD.DropID
   
   DECLARE cur_ORDLINE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT O.Orderkey, OD.OrderLineNumber, OD.Storerkey, OD.Sku, SUM(PD.Qty) AS Qty
   FROM PACKHEADER PH (NOLOCK)
   JOIN ORDERS O (NOLOCK) ON PH.Orderkey = O.Orderkey
   JOIN ORDERDETAIL OD (NOLOCK) ON O.Orderkey = OD.Orderkey      
   JOIN SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku      
   JOIN PICKDETAIL PD (NOLOCK) ON OD.Orderkey = PD.Orderkey AND OD.OrderLineNumber = PD.OrderLineNumber
   WHERE PH.Pickslipno = @c_Pickslipno
   AND SKU.SerialNoCapture IN ('1','3')
   AND (EXISTS(SELECT 1 FROM SERIALNO SN (NOLOCK)
              WHERE SN.Orderkey = O.Orderkey
              AND SN.Storerkey = SKU.Storerkey
              AND SN.Sku = SKU.Sku)
        OR EXISTS(SELECT 1 FROM #TMP_DROPID D
              WHERE D.Storerkey = D.Storerkey
              AND D.Sku = D.Sku)              
        )
   GROUP BY O.Orderkey, OD.OrderLineNumber, OD.Storerkey, OD.Sku
   ORDER BY OD.Sku, OD.OrderLineNumber
   
   OPEN cur_ORDLINE  
          
   FETCH NEXT FROM cur_ORDLINE INTO @C_Orderkey, @c_OrderLineNumber, @c_Storerkey, @c_Sku, @n_Qty

   IF @b_Debug = 1
   BEGIN
      SELECT  '@C_Orderke=' + RTRIM(@C_Orderkey), '@c_OrderLineNumber='+RTRIM(@c_OrderLineNumber), 
              '@c_Storerkey=' + RTRIM(@c_Storerkey), '@c_Sku=' + RTRIM(@c_Sku), 
              '@n_Qty=' + CAST(@n_Qty AS NVARCHAR)
   END
   
   SET @c_Orderkey1sttime = @c_Orderkey
          
   WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
   BEGIN      	      	   	
      IF ISNULL(@c_Orderkey1sttime,'') <> ''
      BEGIN
         UPDATE SERIALNO WITH (ROWLOCK)
      	  SET Pickslipno = ''
      	     ,CartonNo = 0
      	     ,LabelLine = ''
      	     ,TrafficCop = NULL
      	     --,OrderLineNumber = ''
      	  WHERE (Orderkey = @c_Orderkey
      	  OR EXISTS(SELECT 1 FROM #TMP_DROPID
      	       	    WHERE #TMP_DROPID.DropID = SERIALNO.Userdefine01
      	            ) 
      	         )   
      	  AND Storerkey = @c_Storerkey
      
         SET @n_Err = @@ERROR
                             
         IF @n_Err <> 0
         BEGIN
             SELECT @n_Continue = 3 
             SELECT @n_Err = 38010
             SELECT @c_Errmsg='NSQL'+CONVERT(varchar(5),@n_Err)+': Update SERIALNO Table Failed. (ispPAKCF12)'
         END                      
         
         SET @c_Orderkey1sttime = ''                  	 
      END
   	
   	  --Serial no pack by UCC
   	      --Packdetail.dropid(stamp) and Serialno.userdefine01(interface) are UCC#
   	      --no stamping in serialno table when scanning.
   	      --1 carton 1 ucc#
   	  --Serial no pack by Sku (antidiversion)
   	      --stamp serialno.orderkey, status = '6' and orderlinenumumber = cartonno when scanning serial#
   	      --packdetail.dropid is empty
   	      --one carton one label line per sku   	  
      SET @c_SQL = ' 
   	    DECLARE cur_SERIALNO CURSOR FAST_FORWARD READ_ONLY FOR 
   	    SELECT TOP ' + RTRIM(CAST(@n_Qty AS NVARCHAR)) + ' SR.SerialNokey, ISNULL(TD.DropID,''''), 
   	           CASE WHEN TD.DropID IS NULL THEN CAST(SR.OrderLineNumber AS INT) ELSE ISNULL(TD.CartonNo,0) END, 
   	           ISNULL(TD.LabelLine,'''') 
   	    FROM SERIALNO SR (NOLOCK)   	       	
   	    LEFT JOIN #TMP_DROPID TD ON SR.Userdefine01 = TD.DropID AND SR.Storerkey = TD.Storerkey AND SR.Sku = TD.Sku    
   	    WHERE (SR.Orderkey = @c_Orderkey OR TD.DropID IS NOT NULL)      	           	             
   	    AND SR.Storerkey = @c_Storerkey 
   	    AND SR.Sku = @c_Sku
   	    AND SR.Pickslipno = ''''
   	    ORDER BY SR.Userdefine01, SR.SerialNokey '

      EXEC sp_executesql @c_SQL,
         N'@c_Orderkey NVARCHAR(10), @c_Storerkey NVARCHAR(15), @c_Sku NVARCHAR(20)', 
         @c_Orderkey,
         @c_Storerkey,
         @c_Sku
                  
      IF @b_Debug = 1
         PRINT @c_SQL         

      OPEN cur_SERIALNO  

      FETCH NEXT FROM cur_SERIALNO INTO @c_SerialNoKey, @c_DropID, @n_CartonNo, @c_LabelLine
      
      WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
      BEGIN
      	  IF @b_Debug = 1
          BEGIN
             SELECT  '@c_SerialNoKey=' + RTRIM(@c_SerialNoKey) + ' @c_Dropid=' + RTRIM(@c_DropID) + ' @n_cartonno=' + RTRIM(CAST(@c_DropID AS NVARCHAR)) + ' @c_LabelLine=' + RTRIM(@c_LabelLine) 
          END
          
          IF ISNULL(@c_DropId,'') = ''
          BEGIN
          	 SELECT TOP 1 @c_LabelLine = PD.LabelLine
          	 FROM PACKDETAIL PD (NOLOCK)
          	 WHERE PD.Pickslipno = @c_Pickslipno
          	 AND PD.Storerkey = @c_Storerkey
          	 AND PD.Sku = @c_Sku
          	 AND PD.CartonNo = @n_CartonNo
          END

      	  UPDATE SERIALNO WITH (ROWLOCK)
      	  SET Orderkey = @c_Orderkey
      	     ,OrderLineNumber = @c_OrderLineNumber
      	     ,Pickslipno = @c_Pickslipno
      	     ,CartonNo = @n_CartonNo
      	     ,Labelline = @c_LabelLine
      	     ,Status = '6'
      	     ,TrafficCop = NULL
      	  WHERE SerialNokey = @c_SerialNokey

         SET @n_Err = @@ERROR
                             
         IF @n_Err <> 0
         BEGIN
             SELECT @n_Continue = 3 
             SELECT @n_Err = 38020
             SELECT @c_Errmsg='NSQL'+CONVERT(varchar(5),@n_Err)+': Update SERIALNO Table Failed. (ispPAKCF12)'
         END                               	          	  
      	  
         FETCH NEXT FROM cur_SERIALNO INTO @c_SerialNoKey, @c_DropID, @n_CartonNo, @c_LabelLine
      END
      CLOSE cur_SERIALNO
      DEALLOCATE cur_SERIALNO      	       	       	 
   	 
      FETCH NEXT FROM cur_ORDLINE INTO @C_Orderkey, @c_OrderLineNumber, @c_Storerkey, @c_Sku, @n_Qty    
   END
   CLOSE cur_ORDLINE
   DEALLOCATE cur_ORDLINE
                           
    
   QUIT_SP:

   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispPAKCF12'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
        COMMIT TRAN
      END 
      RETURN
   END 
END
GO

GRANT EXECUTE ON [dbo].[ispPAKCF12] TO nSQL 
GO
