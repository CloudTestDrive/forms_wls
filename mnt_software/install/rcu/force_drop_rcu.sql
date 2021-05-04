SET SERVEROUTPUT ON
DECLARE
  filt varchar2(255) := lower('&1%');
  cursor c is select s.sid, s.serial#, s.status, p.spid
      from v$session s, v$process p
      where lower(s.username) like filt
     and p.addr (+) = s.paddr;
  cursor c2 is select username from all_users where lower(username) like filt;   
BEGIN
  DBMS_OUTPUT.PUT_LINE('FILTER: '||filt);
  -- Too dangerous if the filter is too small
  if LENGTH(filt)<4 then
    return;
  end if;  
  for rec in c
  loop
     DBMS_OUTPUT.PUT_LINE('alter system kill session:'||rec.sid); 
     execute immediate 'alter system kill session''' || rec.sid||','||rec.serial# || '''';   
  end loop;
  for rec2 in c2
  loop
     DBMS_OUTPUT.PUT_LINE('drop user '||rec2.username||' cascade'); 
     execute immediate 'drop user '||rec2.username||' cascade';  
  end loop; 
  delete from SCHEMA_VERSION_REGISTRY where lower(MRC_NAME) like filt;
  commit;
END;
/
exit
