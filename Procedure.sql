# Health-based-alcohol

## This PL/SQL script demonstrates a health-based alcohol eligibility system using Oracle's object-relational features

set serveroutput on;

-- Drop types/tables if already exist (for re-runnability)
begin
    execute immediate 'drop table citizens';
exception when others then null;
end;
/

begin
    execute immediate 'drop type c_diseases force';
exception when others then null;
end;
/

-- Create collection type
create or replace type c_diseases as table of varchar2(40);
/

-- Create citizens table
create table citizens (
    citizens_id number primary key,
    names_s varchar2(50),
    health varchar2(20),
    diseases c_diseases
) nested table diseases store as cs_diseases;
/

-- Insert data
insert into citizens values(01,'alice','good',c_diseases());
insert into citizens values(02,'bob','bad',c_diseases('diabetes','asthma','arthritis'));
insert into citizens values(03,'charlie','good',c_diseases());
insert into citizens values(04,'diana','bad',c_diseases('hypertension','migraine'));
insert into citizens values(05,'eve','bad',c_diseases('allergies'));
/

-- Show data
select * from citizens;

-- Create procedure
create or replace procedure alcohol_test(
    p_citizens_id in citizens.citizens_id%type,
    p_age in number
) is
    each_citizens citizens%rowtype;
begin
    -- Fetch citizen
    select * into each_citizens
    from citizens
    where citizens_id = p_citizens_id;

    -- Check conditions
    if p_age < 18 then
        dbms_output.put_line(each_citizens.names_s || ' you are too young to take beer');
        return; -- Exit early
    end if;

    if each_citizens.health = 'bad' then
        dbms_output.put_line(each_citizens.names_s || ' you are suffering from diseases, health is bad');
        -- List diseases if any exist
        if each_citizens.diseases is not null and each_citizens.diseases.count > 0 then
            dbms_output.put_line('Diseases:');
            for i in 1..each_citizens.diseases.count loop
                dbms_output.put_line(' - ' || each_citizens.diseases(i));
            end loop;
        else
            dbms_output.put_line('No specific diseases recorded.');
        end if;
        return;
    else
        dbms_output.put_line(each_citizens.names_s || ' take beer');
    end if;

exception
    when no_data_found then
        dbms_output.put_line('Error: Citizen with ID ' || p_citizens_id || ' not found.');
    when others then
        dbms_output.put_line('Error: ' || sqlerrm);
end alcohol_test;
/

-- CALL THE PROCEDURE CORRECTLY
begin
    alcohol_test(01, 3);
end;
/
