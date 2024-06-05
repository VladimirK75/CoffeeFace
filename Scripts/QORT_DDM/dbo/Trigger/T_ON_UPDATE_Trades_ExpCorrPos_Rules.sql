CREATE trigger dbo.T_ON_UPDATE_Trades_ExpCorrPos_Rules on dbo.ExpCorrPos_Rules
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
                 update dbo.ExpCorrPos_Rules
                    set dbo.ExpCorrPos_Rules.AuditDateTime = getdate()
                  where id in( select id
                                 from inserted )
                 insert into ExpCorrPos_Rules_Log
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
