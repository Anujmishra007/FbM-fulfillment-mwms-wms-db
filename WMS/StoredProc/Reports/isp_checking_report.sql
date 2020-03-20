IF EXISTS (SELECT name 
	   FROM   dbo.sysobjects 
	   WHERE  name = N'isp_checking_report' 
	   AND 	  type = 'P')
    DROP PROCEDURE isp_checking_report
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROC isp_checking_report
   @c_xdockpokey NVARCHAR(8)
AS
BEGIN -- main
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   -- create result table
   BEGIN TRANSACTION
   CREATE TABLE #result
   	(
      pickslipno NVARCHAR(10) NULL,
   	xdockpokey NVARCHAR(8) NULL,
   	sellersreference NVARCHAR(18) NULL,
   	sellername NVARCHAR(45) NULL,
   	storerkey NVARCHAR(15) NULL,
   	sku NVARCHAR(20) NULL,
   	descr NVARCHAR(60) NULL,
   	orderkey NVARCHAR(10) NULL,
   	consigneekey NVARCHAR(10) NULL,
   	company NVARCHAR(45) NULL,
   	totalqty int NULL,
   	casecnt float(53) NULL,
      reprint NVARCHAR(1) NULL
   	)
   COMMIT   

   declare @c_orderkey NVARCHAR(10),
            @c_pickslipno NVARCHAR(10),
            @c_reprint NVARCHAR(1),
            @b_success int,
            @n_err int,
            @c_errmsg NVARCHAR(255)

   select @c_orderkey = ''
   while (1=1)
   begin -- while 1
      select @c_orderkey = min(orderkey)
      from orders (nolock)
      where pokey = @c_xdockpokey
         and orderkey > @c_orderkey

      if @@rowcount = 0 or @c_orderkey is null or @c_orderkey = null
         break

      if not exists (select 1 from pickheader (nolock) where orderkey = @c_orderkey)
      begin
         select @b_success = 0
         EXECUTE nspg_GetKey
            'PICKSLIP',
            9,   
            @c_pickslipno OUTPUT,
            @b_success OUTPUT,
            @n_err OUTPUT,
            @c_errmsg OUTPUT
         
         if @b_success = 1
         begin
            SELECT @c_pickslipno = 'P' + @c_pickslipno
            begin tran
            INSERT INTO PICKHEADER (PickHeaderKey, OrderKey, PickType, Zone, TrafficCop)
                VALUES (@c_pickslipno, @c_orderkey, '0', '3', '')
            select @n_err = @@error
            if @n_err = 0
               commit tran
            else
            begin
               select @c_errmsg = 'Pickheader Insert Failed. (isp_checking_report).'
               RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
               rollback tran
            end
         end
         else
         begin
            RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
            return
         end   
      end
      else -- pickslip already existing
      begin
         select @c_pickslipno = pickheaderkey,
            @c_reprint = 'Y'
         from pickheader (nolock)
         where orderkey = @c_orderkey
      end

      -- insert into #result
      insert #result
         select @c_pickslipno,
            po.xdockpokey, 
      		po.sellersreference,
      		po.sellername,
      		orderdetail.storerkey,
      		orderdetail.sku,
      		sku.descr,
      		orderdetail.orderkey,
      		consigneekey = dbo.fnc_RTrim(substring(orders.consigneekey,5,10)),
      		orders.c_company,
      		totalqty = sum(orderdetail.qtyallocated+qtypicked+shippedqty),
      		convert(int, pack.casecnt),
            @c_reprint
      	from po (nolock) join orders (nolock)    
      		on po.xdockpokey = orders.pokey
      	join orderdetail (nolock)    
      		on orders.orderkey = orderdetail.orderkey
      	join sku (nolock)    
      		on sku.storerkey = orderdetail.storerkey
      			and sku.sku = orderdetail.sku
      	join pack (nolock)     
      		on sku.packkey = pack.packkey
         where orders.orderkey = @c_orderkey
            and po.xdockpokey = @c_xdockpokey
      	group by po.xdockpokey, 
      		po.sellersreference,
      		po.sellername,
      		orderdetail.storerkey,
      		orderdetail.sku,
      		sku.descr,
      		orderdetail.orderkey,
      		orders.consigneekey,
      		orders.c_company,
      		pack.casecnt
         having sum(orderdetail.qtyallocated+qtypicked+shippedqty) > 0       
   end -- while 1

   -- display result
   select * from #result

   begin tran
   drop table #result
   commit tran
END -- main
GO

GRANT EXECUTE ON isp_checking_report TO NSQL
GO

