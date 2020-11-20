if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ispLPPK08]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ispLPPK08]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Procedure: ispLPPK08                                          */
/* Creation Date: 19-SEP-2020                                           */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-15127 CN ZCJ Pre-cartonization                          */   
/*          Orders                                                      */
/*                                                                      */
/* Called By: Load Plan                                                 */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/

CREATE PROC ispLPPK08   
   @cLoadKey    NVARCHAR(10),  
   @bSuccess    INT      OUTPUT,
   @nErr        INT      OUTPUT, 
   @cErrMsg     NVARCHAR(250) OUTPUT
AS   
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF   
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @c_Storerkey                    NVARCHAR(15),
           @c_Facility                     NVARCHAR(5),
           @c_CartonizationGroup           NVARCHAR(10),           
           @c_Sku                          NVARCHAR(20),
           @c_Orderkey                     NVARCHAR(10),
           @c_PickslipNo                   NVARCHAR(10),
           @n_OrderCube                    DECIMAL(12,5),
           @n_CartonNo                     INT,
           @c_LabelNo                      NVARCHAR(20),
           @n_CartonCube                   DECIMAL(12,5),
           @c_CartonType                   NVARCHAR(10),
           @n_StdCube                      DECIMAL(12,5),
           @n_StdGrossWgt                  DECIMAL(12,5),
           @n_QtyPack                      INT,                     
           @n_Qty                          INT,
           @n_LabelLineNo                  INT,
           @c_LabelLineNo                  NVARCHAR(5),
           @n_QtyCanFit                    INT,
           @c_NewCarton                    NVARCHAR(5),
           @c_AssignPackLabelToOrdCfg      NVARCHAR(30)
                                               
   DECLARE @n_Continue   INT,
           @n_StartTCnt  INT,
           @n_debug      INT
   
 	 IF @nerr =  1
	    SET @n_debug = 1
	 ELSE
	    SET @n_debug = 0		 
                                                     
	 SELECT @n_Continue=1, @n_StartTCnt=@@TRANCOUNT, @nErr = 0, @cErrMsg = '', @bsuccess = 1 
	
	 IF @@TRANCOUNT = 0
	    BEGIN TRAN
         
   --Validation            
   IF @n_continue IN(1,2) 
   BEGIN
      IF EXISTS(SELECT 1 FROM PickDetail PD WITH (NOLOCK) 
                JOIN  LOADPLANDETAIL LD WITH (NOLOCK) ON PD.Orderkey = LD.Orderkey 
                WHERE PD.Status='4' AND PD.Qty > 0 
                AND  LD.Loadkey = @cLoadKey)
      BEGIN
         SELECT @n_continue = 3  
         SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38010     
         SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Found Short Pick with Qty > 0 (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '           
         GOTO QUIT_SP 
      END
                                    
      IF NOT EXISTS(SELECT 1
                    FROM LOADPLAN L (NOLOCK)
                    LEFT JOIN PACKHEADER PH (NOLOCK) ON L.Loadkey = PH.Loadkey AND (PH.Orderkey IS NULL OR PH.Orderkey = '')
                    WHERE L.Loadkey = @cLoadkey
                    AND PH.Loadkey IS NULL)              	
      BEGIN
         SELECT @n_continue = 3  
         SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38020     
         SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': No pick record found to generate pack. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '           
         GOTO QUIT_SP 
      END              
   END
   
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
   	  SELECT @c_Storerkey = O.Storerkey,
   	         @c_Facility = O.Facility
   	  FROM LOADPLANDETAIL LPD (NOLOCK)
   	  JOIN ORDERS O (NOLOCK) ON LPD.Orderkey = O.Orderkey
   	  WHERE LPD.Loadkey = @cLoadkey
   	  
   	  SELECT @c_CartonizationGroup = CZ.CartonizationGroup 
   	  FROM FACILITY F (NOLOCK)
   	  JOIN CARTONIZATION CZ (NOLOCK) ON F.Userdefine20 = CZ.CartonizationGroup
   	  AND F.Facility = @c_Facility
   	   	  
   	  IF ISNULL(@c_CartonizationGroup,'') = ''
   	  BEGIN
         SELECT @n_continue = 3  
         SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38030     
         SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Invalid Carton Group Setup. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '           
         GOTO QUIT_SP 
      END
      
      EXECUTE nspGetRight   
      @c_facility,    
      @c_StorerKey,                
      '',                      
      'AssignPackLabelToOrdCfg', -- Configkey  
      @bsuccess    OUTPUT,  
      @c_AssignPackLabelToOrdCfg OUTPUT,  
      @nerr        OUTPUT,  
      @cerrmsg     OUTPUT
      
      IF @bSuccess <> 1
         SET @n_continue = 3            
   END	 

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
   	  SELECT TOP 1 @c_SKU = SKU.Sku
   	  FROM LOADPLANDETAIL LPD (NOLOCK)
   	  JOIN PICKDETAIL PD (NOLOCK) ON LPD.Orderkey = PD.Orderkey
   	  JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
   	  WHERE LPD.Loadkey = @cLoadkey
   	  AND (SKU.Stdcube = 0 OR SKU.Stdcube IS NULL)

   	  IF ISNULL(@c_Sku,'') <> ''
   	  BEGIN
         SELECT @n_continue = 3  
         SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38040     
         SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Invalid stdcube setup for SKU ' + RTRIM(@c_Sku) + ' (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '           
         GOTO QUIT_SP 
      END   	   	    	
   END       
   
   --Precartonization process
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN 	           
      DECLARE CUR_ORDERS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
        SELECT O.Orderkey, SUM(PD.Qty * SKU.StdCube)
        FROM LOADPLANDETAIL LPD (NOLOCK)
        JOIN ORDERS O (NOLOCK) ON LPD.Orderkey = O.Orderkey
        JOIN PICKDETAIL PD (NOLOCK) ON O.Orderkey = PD.Orderkey
        JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
        JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc        
        WHERE LPD.Loadkey = @cLoadkey
        GROUP BY O.Orderkey
        ORDER BY MIN(LOC.LogicalLocation), MIN(LOC.Loc), O.Orderkey

      OPEN CUR_ORDERS
                                
      FETCH NEXT FROM CUR_ORDERS INTO @c_Orderkey, @n_OrderCube
      
      WHILE @@FETCH_STATUS<>-1 AND @n_continue IN(1,2)  
      BEGIN
      	 IF @n_debug = 1 
      	    Print '@c_Orderkey=' + RTRIM(@c_Orderkey) + ' @n_OrderCube=' + CAST(@n_Ordercube AS NVARCHAR)
      	    
      	 --Create pickslip
         EXEC isp_CreatePickSlip
             @c_Orderkey             = @c_Orderkey
            --,@c_LinkPickSlipToPick   = 'Y'  
            ,@c_AutoScanIn           = 'Y'
            ,@b_Success              = @bSuccess OUTPUT
            ,@n_Err                  = @nErr     OUTPUT 
            ,@c_ErrMsg               = @cErrMsg  OUTPUT
   	      
         IF @bSuccess <> 1
            SET @n_continue = 3
            
         SELECT TOP 1 @c_PickslipNo = PH.Pickheaderkey
         FROM PICKHEADER PH (NOLOCK)
         WHERE PH.Orderkey = @c_Orderkey

         IF NOT EXISTS(SELECT 1 FROM PACKHEADER (NOLOCK) WHERE Pickslipno = @c_Pickslipno)
         BEGIN
            INSERT INTO PACKHEADER (Route, OrderKey, OrderRefNo, Loadkey, Consigneekey, StorerKey, PickSlipNo)      
               SELECT TOP 1 O.Route, O.Orderkey, O.ExternOrderkey, O.LoadKey, O.Consigneekey, O.Storerkey, @c_PickSlipNo       
               FROM  PICKHEADER PH (NOLOCK)      
               JOIN  ORDERS O (NOLOCK) ON PH.Orderkey = O.Orderkey    
               WHERE PH.PickHeaderKey = @c_PickSlipNo
                     
            SET @nerr = @@ERROR
            
            IF @nerr <> 0
            BEGIN
               SELECT @n_continue = 3  
               SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38050     
               SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Insert Error On PACKHEADER Table. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '           
            END
         END   

         IF NOT EXISTS(SELECT 1 FROM PACKDETAIL (NOLOCK) WHERE Pickslipno = @c_Pickslipno)
         BEGIN
            DECLARE CUR_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
               SELECT P.SKU, SKU.StdCube, SKU.StdGrossWgt, SUM(P.Qty)  
               FROM PICKDETAIL P (NOLOCK)  
               JOIN LOC (NOLOCK) ON P.Loc = LOC.Loc
               JOIN SKU (NOLOCK) ON P.Storerkey = SKU.Storerkey AND P.Sku = SKU.Sku
               WHERE P.Orderkey = @c_Orderkey
               AND P.Qty > 0                 
               GROUP BY P.SKU, SKU.StdCube, SKU.StdGrossWgt, LOC.LogicalLocation, LOC.Loc
               ORDER BY LOC.LogicalLocation, LOC.Loc, P.SKU
              
            OPEN CUR_PICKDETAIL            
                          
            FETCH NEXT FROM CUR_PICKDETAIL INTO @c_SKU, @n_StdCube, @n_StdGrossWgt, @n_Qty
            
            SET @c_NewCarton = 'Y'            
            SET @n_CartonNo = 0
            DELETE FROM PACKINFO WHERE Pickslipno = @c_PickslipNo 
            
            WHILE @@FETCH_STATUS<>-1  AND @n_continue IN(1,2)
            BEGIN        	
    	      	 IF @n_debug = 1 
            	    Print '@c_SKU=' + RTRIM(@c_SKU) + ' @n_StdCube=' + CAST(@n_StdCube AS NVARCHAR) + ' @n_StdGrossWgt=' + CAST(@n_StdGrossWgt AS NVARCHAR) + ' @n_Qty=' + CAST(@n_Qty AS NVARCHAR)

            	 WHILE @n_Qty > 0 AND @n_continue IN(1,2)
            	 BEGIN            	  
            	    IF @c_NewCarton = 'Y'
            	    BEGIN
            	    	 SET @c_LabelNo = ''
            	    	 SET @n_CartonCube = 0
            	    	 SET @c_CartonType = ''
            	    	 SET @n_LabelLineNo = 0
                     SET @c_NewCarton = 'N'   
            	    	 SET @n_CartonNo = @n_CartonNo + 1
            	    	  
                     EXEC isp_GenUCCLabelNo_Std
                        @cPickslipNo  = @c_Pickslipno,
                        @nCartonNo    = @n_CartonNo,
                        @cLabelNo     = @c_LabelNo OUTPUT, 
                        @b_success    = @bSuccess OUTPUT,
                        @n_err        = @nerr OUTPUT,
                        @c_errmsg     = @cerrmsg OUTPUT
                     
                     IF @bSuccess <> 1
                        SET @n_continue = 3            	     	       
                                          
                     SELECT TOP 1 @c_cartonType = CZ.CartonType, @n_CartonCube = CZ.Cube
                     FROM CARTONIZATION CZ (NOLOCK)
                     WHERE CZ.CartonizationGroup = @c_CartonizationGroup
                     AND CZ.Cube >= @n_OrderCube
                     ORDER BY CZ.Cube
                     
                     IF ISNULL(@n_CartonCube,0) = 0 
                     BEGIN
                        SELECT TOP 1 @c_cartonType = CZ.CartonType, @n_CartonCube = CZ.Cube
                        FROM CARTONIZATION CZ (NOLOCK)
                        WHERE CZ.CartonizationGroup = @c_CartonizationGroup
                        ORDER BY CZ.Cube DESC
                     END                       
                                          
                     IF ISNULL(@n_CartonCube,0) = 0 
                     BEGIN
                        SELECT @n_continue = 3  
                        SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38060     
                        SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Unable to find carton type. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '  
                        BREAK         
                     END

                     IF @n_StdCube > @n_CartonCube
                     BEGIN
                        SELECT @n_continue = 3  
                        SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38070     
                        SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': SKU StdCube greater than carton cube. SKU: ' + RTRIM(@c_Sku) + ' (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '  
                        BREAK         
                     END                     

          	      	 IF @n_debug = 1 
                  	    Print  '@c_CartonizationGroup=' + RTRIM(@c_CartonizationGroup) + ' @c_cartonType=' + RTRIM(@c_cartonType) + ' @n_CartonCube=' + CAST(@n_CartonCube AS NVARCHAR) + ' @n_CartonNo=' + CAST(@n_CartonNo AS NVARCHAR)  
                     
                     INSERT INTO PACKINFO (PickSlipNo, Cartonno, CartonType, Cube, Weight, Qty)
                     VALUES (@c_PickSlipno, @n_CartonNo, @c_CartonType, @n_CartonCube, 0, 0)             
                     
                     SET @nerr = @@ERROR
                     
                     IF @nerr <> 0
                     BEGIN
                        SELECT @n_continue = 3  
                        SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38080     
                        SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Insert Error On PACKINFO Table. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '  
                        BREAK         
                     END                      
            	    END
            	    
            	    SET @n_QtyCanFit = FLOOR(@n_CartonCube / @n_StdCube)
            	    
            	    IF @n_QtyCanFit = 0
            	    BEGIN
            	    	  SET @c_NewCarton = 'Y'
            	    	  CONTINUE
            	    END
            	    
            	    IF @n_Qty >= @n_QtyCanFit
            	    BEGIN
            	       SET @n_QtyPack = @n_QtyCanFit 
            	       SET @c_NewCarton = 'Y'  --Open new carton for remaining qty
            	    END   
            	    ELSE 
            	       SET @n_QtyPack = @n_Qty    

       	      	  IF @n_debug = 1 
                  	 Print '@n_QtyCanFit=' + CAST(@n_QtyCanFit AS NVARCHAR) + ' @n_QtyPack=' + CAST(@n_QtyPack AS NVARCHAR) + ' @n_CartonCube=' + CAST(@n_CartonCube AS NVARCHAR)  + ' @n_OrderCube=' + CAST(@n_OrderCube AS NVARCHAR) + ' @n_Qty=' + CAST(@n_Qty AS NVARCHAR)        
            	    
            	    SET @n_CartonCube = @n_CartonCube - (@n_QtyPack * @n_StdCube)
            	    SET @n_OrderCube = @n_OrderCube - (@n_QtyPack * @n_StdCube)
            	    SET @n_Qty = @n_Qty - @n_QtyPack            	     
            	    
            	    --update packinfo
            	    UPDATE PACKINFO WITH (ROWLOCK)
            	    SET Weight = Weight + (@n_QtyPack * @n_StdGrossWgt)
            	        --Qty = Qty + @n_QtyPack
            	    WHERE Pickslipno = @c_PickslipNo
            	    AND CartonNo = @n_CartonNo
                  
                  SET @nerr = @@ERROR
                  
                  IF @nerr <> 0
                  BEGIN
                     SELECT @n_continue = 3  
                     SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38090     
                     SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Update Error On PACKINFO Table. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '      
                     BREAK     
                  END
            	    
            	    --Create packdetail
            	    IF NOT EXISTS(SELECT 1 FROM PACKDETAIL (NOLOCK) WHERE Pickslipno = @c_Pickslipno AND CartonNo = @n_CartonNo AND Sku = @c_Sku)
            	    BEGIN            	     
            	       SET @n_LabelLineNo = @n_LabelLineNo + 1
            	       SET @c_LabelLineNo = RIGHT('00000' + RTRIM(CAST(@n_LabelLineNo AS NVARCHAR)),5)
            	    
                     INSERT INTO PACKDETAIL(PickSlipNo, CartonNo, LabelNo, LabelLine, StorerKey, SKU, QTY, AddWho, AddDate, EditWho, EditDate)    
                     VALUES     (@c_PickSlipNo, @n_CartonNo, @c_LabelNo, @c_LabelLineNo, @c_StorerKey, @c_SKU,   
                                 @n_QtyPack, sUser_sName(), GETDATE(), sUser_sName(), GETDATE())            	
                     
                     SET @nerr = @@ERROR
                     
                     IF @nerr <> 0
                     BEGIN
                        SELECT @n_continue = 3  
                        SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38100     
                        SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Insert Error On PACKDETAIL Table. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '     
                        BREAK      
                     END
                  END  
                  ELSE
                  BEGIN
                  	  UPDATE PACKDETAIL WITH (ROWLOCK)
                  	  SET Qty = Qty + @n_QtyPack
                  	      --ArchiveCop = NULL
                  	  WHERE Pickslipno = @c_Pickslipno
                  	  AND CartonNo = @n_CartonNo
                  	  AND Sku = @c_Sku                   	
                  
                     SET @nerr = @@ERROR
                     
                     IF @nerr <> 0
                     BEGIN
                        SELECT @n_continue = 3  
                        SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38050     
                        SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Update Error On PACKDETAIL Table. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '    
                        BREAK       
                     END
                  END                                     
               END -- @n_Qty > 0
                               
               FETCH NEXT FROM CUR_PICKDETAIL INTO @c_SKU, @n_StdCube, @n_StdGrossWgt, @n_Qty
            END
            CLOSE CUR_PICKDETAIL 
            DEALLOCATE CUR_PICKDETAIL         	
         END

         /*
         IF NOT EXISTS (SELECT 1 FROM PICKINGINFO (NOLOCK) WHERE PickSlipNo = @c_Pickslipno)
         BEGIN
            INSERT INTO PICKINGINFO (PickSlipNo, ScanInDate)
         	  VALUES (@c_PickslipNo, GETDATE())
         END
               
         UPDATE PICKINGINFO WITH (ROWLOCK)
         SET ScanOutDate = GETDATE()
         WHERE PickslipNo = @c_PickslipNo
         AND (ScanOutDate IS NULL
             OR ScanOutDate = '1900-01-01')
         
         SET @nerr = @@ERROR
         
         IF @nerr <> 0
         BEGIN
            SELECT @n_continue = 3  
            SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38110     
            SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Update Error On PICKINGINFO Table. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '           
         END

         UPDATE PACKHEADER WITH (ROWLOCK)
         SET Status = '9'
         WHERE Pickslipno = @c_Pickslipno
         
         SET @nerr = @@ERROR
         
         IF @nerr <> 0
         BEGIN
            SELECT @n_continue = 3  
            SELECT @cerrmsg = CONVERT(NVARCHAR(250),@nerr), @nerr = 38120     
            SELECT @cerrmsg='NSQL'+CONVERT(NVARCHAR(5),@nerr)+': Update Error On PACKHEADER Table. (ispLPPK08)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@cerrmsg) + ' ) '           
         END   
         */
                        	      	 
         FETCH NEXT FROM CUR_ORDERS INTO @c_Orderkey, @n_OrderCube
      END        	
      CLOSE CUR_ORDERS
      DEALLOCATE CUR_ORDERS                                                        
   END
   
   --update labelno to pickdeetail
   IF (@n_continue = 1 OR @n_continue = 2) AND @c_AssignPackLabelToOrdCfg = '1'
   BEGIN
      DECLARE CUR_PACK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
        SELECT PKH.Pickslipno
        FROM LOADPLANDETAIL LPD (NOLOCK)
        JOIN ORDERS O (NOLOCK) ON LPD.Orderkey = O.Orderkey
        JOIN PACKHEADER PKH (NOLOCK) ON O.Orderkey = PKH.Orderkey
        WHERE LPD.Loadkey = @cLoadkey
        GROUP BY PKH.PickslipNo
        ORDER BY PKH.PickslipNo

      OPEN CUR_PACK
                                
      FETCH NEXT FROM CUR_PACK INTO @c_Pickslipno
      
      WHILE @@FETCH_STATUS<>-1 AND @n_continue IN(1,2)  
      BEGIN
         EXEC isp_AssignPackLabelToOrderByLoad
           @c_PickslipNo = @c_PickslipNo,     
           @b_Success = @bSuccess OUTPUT,  
           @n_err = @nErr OUTPUT,  
           @c_errmsg = @cErrmsg OUTPUT
           
         IF @bSuccess <> 1
            SET @n_continue = 3
                	
         FETCH NEXT FROM CUR_PACK INTO @c_Pickslipno
      END
      CLOSE CUR_PACK
      DEALLOCATE CUR_PACK
   END   
      
   QUIT_SP:

	 IF @n_Continue=3  -- Error Occured - Process AND Return
	 BEGIN
	  SELECT @bSuccess = 0
	 	IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
	 	BEGIN
	 		ROLLBACK TRAN
	 	END
	 	ELSE
	 	BEGIN
	 		WHILE @@TRANCOUNT > @n_StartTCnt
	 		BEGIN
	 			COMMIT TRAN
	 		END
	 	END
	 	EXECUTE dbo.nsp_LogError @nErr, @cErrmsg, 'ispLPPK08'		
	 	RAISERROR (@cErrmsg, 16, 1) WITH SETERROR    -- SQL2012
	 	--RAISERROR @nErr @cErrmsg
	 	RETURN
	 END
	 ELSE
	 BEGIN
	  SELECT @bSuccess = 1
	 	WHILE @@TRANCOUNT > @n_StartTCnt
	 	BEGIN
	 		COMMIT TRAN
	 	END
	 	RETURN
	 END  
END  
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON [ispLPPK08] TO NSQL
GO
