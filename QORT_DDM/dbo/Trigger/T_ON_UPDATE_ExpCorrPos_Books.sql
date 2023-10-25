
CREATE   trigger [dbo].[T_ON_UPDATE_ExpCorrPos_Books] on [dbo].[ExpCorrPos_Books]
after update
as
     begin
         set nocount on
         if not exists( select 1
                          from inserted )
            and not exists( select 1
                              from deleted )
             return
              else
             begin
                 update dbo.ExpCorrPos_Books
                    set dbo.ExpCorrPos_Books.AuditDateTime = getdate()
                  where id in( select id
                                 from inserted )
                 insert into ExpCorrPos_Books_Log
                 select *
                      , AuditDateTime_log = getdate()
                      , AuditActions = 'D'
                      , AuditUser = suser_name()
                   from deleted
                 union all
                 select *
                      , AuditDateTime_log = getdate()
                      , AuditActions = 'I'
                      , AuditUser = suser_name()
                   from inserted
         end
     end
