SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/**************************************************************************/
/* SP: mspPopulateToASN_DEFFA                                             */
/* Creation Date: 19-June-2024                                            */
/* Copyright: LF                                                          */
/* Written by:               						                                  */
/*                                                                        */
/* Purpose: UWP-20527 DEFFA Auto Create ASN From Ordertype is factory     */
/*                                                                        */
/* Input Parameters: Orderkey                                             */
/*                                                                        */
/* Output Parameters: NONE                                                */
/*                                                                        */
/* Return Status: NONE                                                    */
/*                                                                        */
/* Usage:                                                                 */
/*                                                                        */
/* Local Variables:                                                       */
/*                                                                        */
/*                                                                        */
/* Called By: 						                                                */
/*                                                                        */
/* PVCS Version: 1.0                                                      */
/*                                                                        */
/* Version:1.0                                                       	    */
/*                                                                        */
/* Data Modifications:                                                    */ 
/*                                                                        */
/*                                                                        */
/* Updates:                                                               */
/*Date         Author  Ver. Purposes                                      */
/**************************************************************************/

CREATE OR ALTER PROCEDURE mspPopulateToASN_DEFFA 
   @c_OrderKey NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON			
   SET QUOTED_IDENTIFIER OFF	
   SET ANSI_NULLS OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF

  DECLARE   @c_ExternReceiptKey    NVARCHAR(20),
	    @c_ExternReceiptKeyDet NVARCHAR(20),
            @c_SKU                 NVARCHAR(20),
            @c_PackKey             NVARCHAR(10),
            @c_UOM                 NVARCHAR(5),
            @c_StorerKey           NVARCHAR(15),
            @c_ToStorerKey         NVARCHAR(15),
            @c_OrderLine           NVARCHAR(5),
            @c_ToFacility          NVARCHAR(5),
            @c_ExternOrderLine     NVARCHAR(20),
	    @c_ID		   NVARCHAR(18),
	    @c_ToLoc	           NVARCHAR(10),
	    @c_Type                NVARCHAR(10),
	    @c_WarehouseReference  NVARCHAR(18),
	    @c_Pickdetailkey       NVARCHAR(10),
	    @c_DocType             NCHAR(1),
	    @c_SerialNo		   NVARCHAR(30)
                                   
   DECLARE  @c_Lottable01          NVARCHAR(18),
            @c_Lottable02          NVARCHAR(18),
            @c_Lottable03          NVARCHAR(18),
            @d_Lottable04          DATETIME,
            @d_Lottable05          DATETIME,
            @c_Lottable06          NVARCHAR(30),
            @c_Lottable07          NVARCHAR(30),
            @c_Lottable08          NVARCHAR(30),
            @c_Lottable09          NVARCHAR(30),
            @c_Lottable10          NVARCHAR(30),
            @c_Lottable11          NVARCHAR(30),
            @c_Lottable12          NVARCHAR(30),
            @d_Lottable13          DATETIME,
            @d_Lottable14          DATETIME,
            @d_Lottable15          DATETIME
                                   
   DECLARE  @c_NewReceiptKey       NVARCHAR(10),
            @c_FoundReceiptKey     NVARCHAR(10),
            @c_ReceiptLine         NVARCHAR(5),
            @n_LineNo              INT,
            @n_QtyReceived         INT,
            @n_QtyExpected         INT,        
            @n_ShippedQty          INT,
            @n_BeforeReceivedQty   INT,
            @c_FinalizeFlag        NCHAR(1)
                                   
   DECLARE @c_OUserdefine01        NVARCHAR(20),
           @c_OUserdefine02        NVARCHAR(20),
           @d_OUserdefine06        DATETIME,
           @d_OUserdefine07        DATETIME,
           @c_Carrierkey           NVARCHAR(15),
           @c_CarrierName          NVARCHAR(30),
           @c_CarrierReference     NVARCHAR(18),
           @n_UnitPrice            FLOAT,
           @c_CarrierAddress1      NVARCHAR(45)                        
                                   
   DECLARE  @n_continue            INT,
            @b_success             INT,
            @n_err                 INT,
            @c_errmsg              NVARCHAR(255),
            @n_starttcnt	   INT
            
   SELECT @n_continue = 1, @b_success = 1, @n_err = 0, @n_StartTCnt=@@TRANCOUNT 
   SELECT @c_ID = '', @c_ToLoc = '', @c_FinalizeFlag = 'N'

   --BEGIN TRAN	

   -- insert into Receipt Header

   IF @n_continue = 1 OR @n_continue = 2  
   BEGIN     	        
     SELECT TOP 1 
            @c_ExternReceiptKey   = ORDERS.ExternOrderkey, 
            @c_WarehouseReference = ORDERS.Orderkey,
            @c_Type               = ORDERS.Type,
            @c_ToFacility         = ORDERS.Consigneekey,             
            @c_ToStorerkey        = ORDERS.Storerkey,
            @c_Storerkey          = ORDERS.Storerkey,
            @c_DocType            = 'A',						
            @c_Carrierkey         = ORDERS.BillToKey,
            @c_CarrierName        = ORDERS.B_Contact1,
            @c_CarrierReference   = ORDERS.B_Company,
            @c_OUserdefine01      = ORDERS.Userdefine01,
            @c_OUserdefine02      = ORDERS.Userdefine02,
            @d_OUserdefine06      = ORDERS.Userdefine06,
            @d_OUserdefine07      = ORDERS.Userdefine07,
            @c_ToLoc              = ISNULL(CODELKUP.UDF01,''), 
            @c_CarrierAddress1    = ORDERS.B_Address1  
     FROM  ORDERS WITH (NOLOCK)
     LEFT JOIN  CODELKUP WITH (NOLOCK) ON ORDERS.Type = CODELKUP.Code AND CODELKUP.ListName = 'ORDTYP2ASN' 
     WHERE ORDERS.OrderKey = @c_OrderKey AND ORDERS.Type='FACTORY'       
     
     IF EXISTS(SELECT 1 FROM ORDERDETAIL (NOLOCK) WHERE OrderKey = @c_Orderkey
               HAVING COUNT(DISTINCT ExternOrderkey) > 1)
     BEGIN
        SET @c_ExternReceiptKey  = ''
     END                
     
     IF ISNULL(@c_toloc,'') = ''     
   	    SELECT @c_ToLoc = Userdefine04 
        FROM FACILITY f WITH (NOLOCK)
        WHERE f.Facility = @c_ToFacility

     IF ISNULL(@c_ToLoc,'') = ''
        SET @c_ToLoc = 'DEFDASTG'        

	IF EXISTS(SELECT 1 FROM SerialNo WITH (NOLOCK) where OrderKey=@c_OrderKey AND StorerKey=@c_StorerKey )   
	BEGIN
   	    SELECT @c_SerialNo = SerialNo FROM SerialNo WITH (NOLOCK) where OrderKey=@c_OrderKey AND StorerKey=@c_StorerKey 
	END
	ELSE
	BEGIN
		SET @n_continue = 3
		SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
		SET @n_err = 66001   
	    SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid To SerialNo : ' + RTRIM(ISNULL(@c_SerialNo,'')) +
                        ' (mspPopulateToASN_DEFFA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
	END
	
      
     
     IF NOT EXISTS ( SELECT 1 FROM FACILITY WITH (NOLOCK) WHERE Facility = @c_ToFacility )
		 BEGIN
		 	SET @n_continue = 3
		 	SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
		 	SET @n_err = 66002   
	    SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid To Facility: ' + RTRIM(ISNULL(@c_ToFacility,'')) +
                        ' (mspPopulateToASN_DEFFA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
		 END
    		 	  	
    		 
     IF NOT EXISTS ( SELECT 1 FROM LOC WITH (NOLOCK) WHERE LOC = @c_ToLoc) 
		 BEGIN
		 	SET @n_continue = 3
		 	SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
		 	SET @n_err = 66003   
	    SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid To Loc (Facility.Userdefine04/Codelkup.UDF01 ListName=''ORDTYP2ASN''): ' + RTRIM(ISNULL(@c_ToLoc,'')) +
                        ' (mspPopulateToASN_DEFFA)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
		 END
		     
	   IF @n_continue = 1 OR @n_continue = 2
	   BEGIN 				
	      IF ISNULL(RTRIM(@c_ToStorerKey),'') <> '' -- IS NOT NULL
	      BEGIN
	      	 SELECT TOP 1 @c_FoundReceiptKey = Receiptkey
	      	 FROM RECEIPT(NOLOCK)
	      	 WHERE Externreceiptkey = @c_ExternReceiptKey
	      	 AND Warehousereference = @c_WarehouseReference
	      	 AND storerkey = @c_ToStorerKey
	      	 AND Rectype = @c_Type
	      	 AND Facility = @c_ToFacility
	      	 AND Doctype = @c_DocType 	      	 
	      	 AND ISNULL(Externreceiptkey,'') <> ''
	      	 AND ISNULL(Warehousereference,'') <> ''
	      	 AND Status <> '9'
	      	 
	      	 IF ISNULL(@c_FoundReceiptKey,'') <> ''
	      	 BEGIN
	      	 	  SELECT @c_NewReceiptKey = @c_FoundReceiptKey
	      	 END
	      	 ELSE
	      	 BEGIN
	            -- get next receipt key
	            SELECT @b_success = 0
	            EXECUTE   nspg_getkey
	            'RECEIPT'
	            , 10
	            , @c_NewReceiptKey OUTPUT
	            , @b_success OUTPUT
	            , @n_err OUTPUT
	            , @c_errmsg OUTPUT
	            
	            IF @b_success = 1
	            BEGIN
	               INSERT INTO RECEIPT (ReceiptKey, ExternReceiptkey, Warehousereference, StorerKey, RecType, 
					    Facility, DocType, RoutingTool, Carrierkey, CarrierReference, CarrierName,
	                                    Userdefine01, Userdefine02, Userdefine06, Userdefine07, CarrierAddress1, Status)
	               VALUES (@c_NewReceiptKey, @c_ExternReceiptKey, @c_WarehouseReference, @c_ToStorerKey, 
			       @c_Type, @c_ToFacility, @c_DocType, 'N', @c_Carrierkey, @c_CarrierReference, 				
			       @c_CarrierName,@c_OUserdefine01, @c_OUserdefine02, @d_OUserdefine06, @d_OUserdefine07, @c_CarrierAddress1,0)  
              
				 SET @n_err = @@Error
                 IF @n_err <> 0
                 BEGIN
 	            			 SET @n_continue = 3
	                   SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
				             SET @n_err = 66004   
	   		             SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Error on Table Receipt (mspPopulateToASN_DEFFA)' + ' ( ' + 
                                ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
                 END
	            END
	            ELSE
	            BEGIN
	               SET @n_continue = 3
	               SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err) 
					       SET @n_err = 66005   
	   			       SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Generate Receipt Key Failed! (mspPopulateToASN_DEFFA)' 
	   			                 + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
	            END
	         END
	      END    
	      ELSE
	      BEGIN
	         SET @n_continue = 3
	         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)
				   SET @n_err = 66006   
	   		   SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Storer Key is BLANK! (mspPopulateToASN_DEFFA)' + ' ( ' + 
                          ' SQLSvr MESSAGE=' + RTRIM(ISNULL(@c_errmsg,'')) + ' ) '
	      END
	   END -- if continue = 1 or 2

	   IF @n_continue = 1 OR @n_continue = 2
	   BEGIN         
	      SELECT @c_OrderLine = SPACE(5), @n_LineNo = 1
	      SELECT @c_ExternOrderLine = SPACE(5)
	      
	      IF ISNULL(@c_FoundReceiptKey,'') <> ''
	      BEGIN
	      	 SELECT @n_LineNo = CONVERT(INT,MAX(ReceiptLineNumber)) + 1 
	      	 FROM RECEIPTDETAIL (NOLOCK)
	      	 WHERE Receiptkey = @c_FoundReceiptKey	      
	      	 
	      	 IF ISNULL(@n_LineNo,0) = 0
	      	    SET @n_LineNo = 1	 
	      END   
			
	      WHILE 1=1
	      BEGIN         
	         SELECT TOP 1 @c_SKU        = SKU.SKU,   
	                @c_PackKey    = ORDERDETAIL.PackKey,   
	                @c_UOM        = ORDERDETAIL.UOM,   
	                @n_ShippedQty = (ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked + ORDERDETAIL.SHIPPEDQTY),
	         	    @c_OrderLine  = ORDERDETAIL.OrderLineNumber,
	                @c_ExternOrderLine = ISNULL(ORDERDETAIL.ExternLineNo,''),
	                @n_UnitPrice  = ISNULL(ORDERDETAIL.UnitPrice, 0),
	                @c_ExternReceiptKeyDet = ORDERDETAIL.ExternOrderKey,
					@c_Lottable01=ORDERDETAIL.Lottable01,
					@c_Lottable02=ORDERDETAIL.Lottable02
	         FROM ORDERDETAIL WITH (NOLOCK)
	         JOIN ORDERS WITH (NOLOCK) ON (ORDERS.OrderKey = ORDERDETAIL.OrderKey) 
	         JOIN SKU    WITH (NOLOCK) ON (SKU.StorerKey = ORDERDETAIL.StorerKey AND SKU.Sku = ORDERDETAIL.Sku) 
			 
	         WHERE ( ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked + ORDERDETAIL.SHIPPEDQTY > 0 ) AND  
	               ( ORDERDETAIL.OrderKey = @c_orderkey ) AND             
				    		 ( ORDERDETAIL.OrderLineNumber > @c_OrderLine ) AND  ORDERS.Type=@c_Type 
	         ORDER by ORDERDETAIL.OrderLineNumber
           
	         IF @@ROWCOUNT = 0
	            BREAK
	         
	         SET ROWCOUNT 0 				  
				              
				   IF @n_continue = 1 OR @n_continue = 2 --Based on Pickdetail
	   		   BEGIN 	   		   
		          IF ISNULL(RTRIM(@c_OrderKey),'') <> '' AND   
		             ISNULL(RTRIM(@c_OrderLine),'') <> ''
					 
					 BEGIN
		               DECLARE PICK_CUR CURSOR FAST_FORWARD READ_ONLY FOR 
			                SELECT SUM(PICKDETAIL.Qty) AS Qty,
			                       LOTATTRIBUTE.Lottable02,
				   		 			         LOTATTRIBUTE.Lottable08,
				   		 			         LOTATTRIBUTE.Lottable11
			                FROM PICKDETAIL   WITH (NOLOCK) 
			                JOIN LotAttribute WITH (NOLOCK) ON (PickDetail.LOT = LotAttribute.LOT)
			                WHERE (PICKDETAIL.OrderKey = @c_OrderKey AND
			                       PICKDETAIL.OrderLineNumber = @c_OrderLine)
			                GROUP BY LOTATTRIBUTE.Lottable02, LOTATTRIBUTE.Lottable08, LOTATTRIBUTE.Lottable11      
			       
			             OPEN PICK_CUR
			             
			             FETCH NEXT FROM PICK_CUR
			                INTO @n_ShippedQty, @c_Lottable02, @c_Lottable08, @c_Lottable11
			        
			             WHILE @@FETCH_STATUS <> -1
			             BEGIN
			                SELECT @c_ReceiptLine = RIGHT( '0000' + RTRIM(CAST(@n_LineNo AS NVARCHAR(5))), 5)
			        
			                IF @c_FinalizeFlag = 'Y'
			                BEGIN
			                   SELECT @n_QtyExpected = @n_ShippedQty 
			                   SELECT @n_BeforeReceivedQty = @n_ShippedQty
			                   SELECT @n_QtyReceived = @n_ShippedQty 
			                END
			                ELSE
			                BEGIN
			                   SELECT @n_QtyExpected = 1 
			                   SELECT @n_BeforeReceivedQty = 0
			                   SELECT @n_QtyReceived = 0 
			                END
			                   			                   			                                
			                INSERT INTO RECEIPTDETAIL (ReceiptKey,ReceiptLineNumber,ExternReceiptkey,    
			                                           ExternLineNo,StorerKey,SKU, 
			                                           QtyExpected,QtyReceived,          
			                                           UOM,PackKey,ToLoc,
			                                           Lottable02,Lottable08,Lottable11,
								   BeforeReceivedQty,FinalizeFlag,ToID,UnitPrice, 
								   status, UserDefine01, Lottable01)			                                          
			                            VALUES        (@c_NewReceiptKey, 	  	@c_ReceiptLine,      @c_ExternReceiptkeyDet,   
			                                           @c_ExternOrderLine,	 	@c_ToStorerKey,      @c_SKU,
			                                           @n_QtyExpected,      	@n_QtyReceived,					
			                                           @c_UOM,            		@c_Packkey,          @c_Toloc,			                                           
			                                           @c_Lottable02,       	@c_Lottable08,	     @c_Lottable11,	   		 											   	   @n_BeforeReceivedQty,	@c_FinalizeFlag,     @c_ID,	
				   		 		   @n_UnitPrice,0, 		@c_SerialNo,	     @c_Lottable01)	
																							 
																							 
						EXEC wm.lsp_FinalizeReceipt_Wrapper
								@c_NewReceiptKey
								, @c_ReceiptLine
								,@b_success OUTPUT
								, @n_err OUTPUT
								, @c_errmsg OUTPUT	

								IF @b_success = 0 OR @n_Err <> 0
								BEGIN
									SET @n_Continue = 3
									GOTO QUIT_SP
								END
								
			                SELECT @n_LineNo = @n_LineNo + 1
			        
			                FETCH NEXT FROM PICK_CUR
			                   INTO @n_ShippedQty, @c_Lottable02, @c_Lottable08, @c_Lottable11 
			             END -- WHILE @@FETCH_STATUS <> -1
			             DEALLOCATE PICK_CUR
		          END

				   END
	      END --while
     END
     SET ROWCOUNT 0
 		
		 QUIT_SP:

		 IF @n_continue = 3  -- Error Occured - Process And Return
	   BEGIN
	      SELECT @b_success = 0
	   
	      --IF @@TRANCOUNT = 1 OR @@TRANCOUNT >= @n_starttcnt
	      --BEGIN
	         --ROLLBACK TRAN
	      --END
	      EXECUTE nsp_logerror @n_err, @c_errmsg, 'mspPopulateToASN_DEFFA'
	      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    
	      RETURN
	   END
	   ELSE
	   BEGIN
	      SELECT @b_success = 1
	      -- WHILE @@TRANCOUNT >= @n_starttcnt
	      -- BEGIN
	      --    COMMIT TRAN
	      -- END
	      RETURN
	   END        
	END -- if continue = 1 or 2 001
END


