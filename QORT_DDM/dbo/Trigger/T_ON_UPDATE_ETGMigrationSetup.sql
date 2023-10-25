CREATE   trigger [dbo].[T_ON_UPDATE_ETGMigrationSetup] on [dbo].[ETGMigrationSetup]
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
                 update dbo.ETGMigrationSetup
                    set dbo.ETGMigrationSetup.AuditDateTime = getdate()
                  where id in( select id
                                 from inserted )
                 insert into dbo.ETGMigrationSetup_Log
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
