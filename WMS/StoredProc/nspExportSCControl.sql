if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nspExportSCControl]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[nspExportSCControl]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/************************************************************************/
/* Stored Procedure: nspExportSCControl                                 */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/************************************************************************/

CREATE procedure nspExportSCControl
as
begin
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF

   select count (distinct orderdetail.mbolkey),
   count (orderdetail.mbolkey),
   sum(distinct convert(int, orderdetail.mbolkey)),
   sum(convert(int,orderdetail.mbolkey)),
   Adddate =  RIGHT(dbo.fnc_RTrim("00" + CONVERT(char(4), DATEPART(year, getdate()))),4) +
   RIGHT(dbo.fnc_RTrim("0" + CONVERT(char(2), DATEPART(month, getdate()))),2) +
   RIGHT(dbo.fnc_RTrim("0" + CONVERT(char(2), DATEPART(day, getdate()))),2),
   Addtime = getdate()
   from orders (nolock),
   orderdetail (nolock),
   transmitlog (nolock)
   where orders.orderkey = orderdetail.orderkey
   and orderdetail.mbolkey = transmitlog.key1
   and orderdetail.externorderkey = transmitlog.key3
   and transmitlog.tablename = 'MBOL'
   and transmitlog.transmitflag = '0'
   and orders.status = '9'
end

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

GRANT EXECUTE ON nspExportSCControl to nSQL
GO
