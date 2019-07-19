set echo on
spool e:setup.txt

/* ---------------
   Create table structure for IS 480 class
   --------------- */

drop table waitlist;
drop table enrollments;
drop table prereq;
drop table schclasses;
drop table courses;
drop table students;
drop table majors;

-----
-----


create table MAJORS
	(major varchar2(3) Primary key,
	mdesc varchar2(30));
insert into majors values ('ACC','Accounting');
insert into majors values ('FIN','Finance');
insert into majors values ('IS','Information Systems');
insert into majors values ('MKT','Marketing');

create table STUDENTS 
	(snum varchar2(3) primary key,
	sname varchar2(10),
	standing number(1),
	major varchar2(3) constraint fk_students_major references majors(major),
	gpa number(2,1),
	major_gpa number(2,1));

insert into students values ('101','Andy',3,'IS',2.8,3.2);
insert into students values ('102','Betty',2,null,1.9,null);
insert into students values ('103','Cindy',3,'IS',2.5,3.5);
insert into students values ('104','David',2,'FIN',3.3,3.0);
insert into students values ('105','Ellen',1,null,2.8,null);
insert into students values ('106','Frank',3,'MKT',1.8,2.9);
insert into students values ('107','Gavin',1,null,1.5,2.0);

create table COURSES
	(dept varchar2(3) constraint fk_courses_dept references majors(major),
	cnum varchar2(3),
	ctitle varchar2(30),
	crhr number(3),
	standing number(1),
	primary key (dept,cnum));

insert into courses values ('IS','300','Intro to MIS',3,1);
insert into courses values ('IS','301','Business Communicatons',3,2);
insert into courses values ('IS','310','Statistics',3,2);
insert into courses values ('IS','340','Programming',3,3);
insert into courses values ('IS','380','Database',3,3);
insert into courses values ('IS','385','Systems',3,3);
insert into courses values ('IS','480','Adv Database',3,4);

create table SCHCLASSES (
	callnum number(5) primary key,
	year number(4),
	semester varchar2(3),
	dept varchar2(3),
	cnum varchar2(3),
	section number(2),
	capacity number(3));

alter table schclasses 
	add constraint fk_schclasses_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);

insert into schclasses values (10110,2014,'Fa','IS','300',1,3);
insert into schclasses values (10115,2014,'Fa','IS','300',2,3);
insert into schclasses values (10120,2014,'Fa','IS','300',3,3);
insert into schclasses values (10125,2014,'Fa','IS','301',1,3);
insert into schclasses values (10130,2014,'Fa','IS','301',2,3);
insert into schclasses values (10135,2014,'Fa','IS','310',1,3);
insert into schclasses values (10140,2014,'Fa','IS','310',2,3);
insert into schclasses values (10145,2014,'Fa','IS','340',1,3);
insert into schclasses values (10150,2014,'Fa','IS','380',1,3);
insert into schclasses values (10155,2014,'Fa','IS','385',1,3);
insert into schclasses values (10160,2014,'Fa','IS','480',1,3);

create table PREREQ
	(dept varchar2(3),
	cnum varchar2(3),
	pdept varchar2(3),
	pcnum varchar2(3),
	primary key (dept, cnum, pdept, pcnum));
alter table Prereq 
	add constraint fk_prereq_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);
alter table Prereq 
	add constraint fk_prereq_pdept_pcnum foreign key 
	(pdept, pcnum) references courses (dept,cnum);

insert into prereq values ('IS','380','IS','300');
insert into prereq values ('IS','380','IS','301');
insert into prereq values ('IS','380','IS','310');
insert into prereq values ('IS','385','IS','310');
insert into prereq values ('IS','340','IS','300');
insert into prereq values ('IS','480','IS','380');

create table ENROLLMENTS (
	snum varchar2(3) constraint fk_enrollments_snum references students(snum),
	callnum number(5) constraint fk_enrollments_callnum references schclasses(callnum),
	grade varchar2(2),
	primary key (snum, callnum));

insert into enrollments values (101,10110,'A');
insert into enrollments values (101,10135,null);
insert into enrollments values (101,10125,null);
insert into enrollments values (101,10145,'C');
insert into enrollments values (102,10110,'B');
insert into enrollments values (102,10130,null);
insert into enrollments values (103,10120,'A');
insert into enrollments values (104,10110,null);
insert into enrollments values (102,10125,'B');


ALTER SESSION SET nls_date_format = 'DD-MM-YYYY HH24:MI:SS';

create table WAITLIST (
	snum varchar2(3) constraint fk_waitlist_snum references students(snum),
	callnum number(5) constraint fk_waitlist_callnum references schclasses(callnum),
	wldate date,
	primary key (snum, callnum));


insert into Waitlist values (105,10110, sysdate);
insert into Waitlist values (106,10125, sysdate);
insert into Waitlist values (101,10110, sysdate-.23);
insert into Waitlist values (104,10125, sysdate-.27);
insert into Waitlist values (103,10145, sysdate-.10);
insert into Waitlist values (107,10145, sysdate-.33);
insert into Waitlist values (105,10125, sysdate-.41);

	commit;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------




/* This program is for Final Project */

create or replace package Enroll is

-- add me section

procedure Validate_Student
	(p_snum students.snum%type, p_Error_Text out varchar2);
	
procedure Validate_Callnumber
	(p_callnum enrollments.callnum%type, p_Error_Text out varchar2);

procedure Repeat_Enrollment
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);
	
procedure Double_Enrollment
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);
	
procedure Student_Max_Units
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);
	
procedure Standing_Enrollment
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);
	
procedure Disqualified_Student
	(p_snum enrollments.snum%type, p_Error_Text out varchar2);
	
procedure Open_Class
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);

procedure Wait_list
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);
	
procedure Repeat_Wait_list
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);
	
procedure AddMe
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
		p_ErrorMsg out varchar2);

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

-- drop my section

procedure Not_Enrolled
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);
	
procedure Already_Graded
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);
	
procedure Check_Waiting 
	(p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2);

procedure DropMe
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type );
		
end Enroll;
/

-- show compiling errors and pause
show err
pause
------------------------------------------------------------------------

create or replace package body Enroll is

-- this is to validate the student
procedure Validate_Student
	(p_snum students.snum%type, p_Error_Text out varchar2) as
	v_count number(3);

begin
	-- validate the student 
	select count(*) into v_count
	from students
	where snum=p_snum;
	
	if v_count = 1 then
		p_Error_Text:= null;
	else
		p_Error_Text:= 'Student Number ' || p_snum || ' Invalide. ';			
	end if;
	
end;
------------------------------------------------------------------------

-- this is to validate the call number
procedure Validate_Callnumber
	(p_callnum enrollments.callnum%type, p_Error_Text out varchar2) as
	v_count number(3);

begin
	-- validate the callnumber 
	select count(*) into v_count
	from schclasses
	where callnum=p_callnum;
	
	if v_count = 1 then
		p_Error_Text:= null;
	else
		p_Error_Text:= 'Call number ' || p_callnum || ' Invalide. ';			
	end if;
	
end;
------------------------------------------------------------------------

-- this procedure is to make sure the student isn't already enrolled in the class
procedure Repeat_Enrollment
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	v_count number(3);
	
begin
	select count(*) into v_count
	from enrollments
	where snum=p_snum and callnum=p_callnum;
	
	if v_count = 1 then
		p_Error_Text:= p_snum||', you are already enrolled in '|| p_callnum||'. ';
	else
		p_Error_Text:= null;			
	end if;
	
end;

------------------------------------------------------------------------------------

-- this procedure is to check for double enrollments in different sections
procedure Double_Enrollment
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	v_count number(3);
	v_dept schclasses.dept%type;
	v_cnum schclasses.cnum%type;
	
begin
	-- get dept and cnum from the callnum
	select dept, cnum
	into v_dept, v_cnum
	from schclasses
	where callnum=p_callnum;

	select count(*) into v_count
	from enrollments, schclasses
	where snum=p_snum and dept=v_dept and cnum=v_cnum and enrollments.callnum!=p_callnum
		and enrollments.callnum=schclasses.callnum;

	
	if v_count = 1 then
		p_Error_Text:= p_snum||', you are already enrolled in a different section of '|| v_dept||' '|| v_cnum||'. ';
	else
		p_Error_Text:= null;			
	end if;
	
end;

------------------------------------------------------------------------

-- this is so the student can't register for more than 15 units
procedure Student_Max_Units
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	v_current_units number;
	v_toadd_units number;
	
begin
	-- find current units the student has
	select nvl(sum(crhr),0) into v_current_units
	from schclasses sch, enrollments e, courses c
	where e.snum=p_snum
			and e.callnum=sch.callnum
			and sch.dept=c.dept
			and sch.cnum=c.cnum;
	
	-- find units to add
	select crhr into v_toadd_units
	from schclasses sch, courses c
	where sch.callnum=p_callnum
		and sch.dept=c.dept
		and sch.cnum=c.cnum;
	
	if v_current_units + v_toadd_units <= 15 then
		p_Error_Text:= null;
	else
		p_Error_Text:= p_snum ||' has hit 15 unit limit. Can NOT add any more courses. ';		
	end if;
	
end;

--------------------------------------------------------------------------------

-- procedure to check if student has a high enough standing
procedure Standing_Enrollment
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	v_s_standing number(3);
	v_c_standing number(3);
	
begin
	select standing into v_s_standing
	from students 
	where snum=p_snum;

	select standing into v_c_standing
	from schclasses, courses
	where callnum=p_callnum
		and schclasses.dept=courses.dept and schclasses.cnum=courses.cnum;

	
	if v_s_standing >= v_c_standing then
		p_Error_Text:= null;
	else
		p_Error_Text:= p_snum||', you are not a high enough standing to take '||p_callnum||'. ';			
	end if;
	
end;
-----------------------------------------------------------------------------------------
-- to check if non freshman student is not below 2.0 on gpa
procedure Disqualified_Student
	(p_snum enrollments.snum%type, p_Error_Text out varchar2) as
	v_gpa students.gpa%type;
	v_standing students.standing%type;
	
begin
	select nvl(gpa, 0) into v_gpa
	from students
	where snum=p_snum;

	select standing into v_standing
	from students
	where snum=p_snum;

	if v_standing < 2 then
		p_Error_Text:= null;
	else
		if v_gpa < 2 then
			p_Error_Text:= p_snum||', you are in a disqualified status. ';
		else
			p_Error_Text:= null;
		end if;
	end if;
		
end;
-----------------------------------------------------------------------------------------
-- check capacity on class
procedure Open_Class
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	v_sc_capacity number;
	v_e_capacity number;
	
begin
	-- capacity of the class
	select capacity into v_sc_capacity
	from schclasses
	where callnum=p_callnum;
	
	-- to count how many students are currently enrolled for a class
	select count(callnum) into v_e_capacity
	from enrollments
	where callnum=p_callnum and nvl(grade,'T')!='W';
	
	if v_e_capacity < v_sc_capacity then
		p_Error_Text:= null;
	else
		p_Error_Text:= p_snum||', '|| p_callnum || ' is full. ';
	end if;
	
end;
------------------------------------------------------------------------
-- to add to waitlist
procedure Wait_list
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	v_sc_capacity number;
	v_e_capacity number;
	
begin
	-- capacity of the class
	select capacity into v_sc_capacity
	from schclasses
	where callnum=p_callnum;
	
	-- to count how many students are currently enrolled for a class
	select count(callnum) into v_e_capacity
	from enrollments
	where callnum=p_callnum and nvl(grade,'T')!='W';
	
	if v_e_capacity < v_sc_capacity then
		p_Error_Text:= null;
	else
		insert into Waitlist values (
			p_snum, p_callnum, sysdate);
		p_Error_Text:= 'You are now on the wait list for class number ' ||p_callnum|| '. ';		
	end if;
	commit;
end;
------------------------------------------------------------------------
-- to make sure student is not already on  waitlist
procedure Repeat_Wait_list
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	v_count number(3);
	
begin
	select count(*) into v_count
	from waitlist
	where snum=p_snum and callnum=p_callnum;
	
	if v_count = 1 then
		p_Error_Text:= p_snum||', you are already on the waitlist for '|| p_callnum;
	else
		p_Error_Text:= null;			
	end if;
	
end;
------------------------------------------------------------------------
-- main procedure to enroll (add) a student
procedure AddMe
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
		p_ErrorMsg out varchar2) as
	v_error_msg varchar2(2000);
	v_error_text varchar2(2000);
	v_count number(3);

begin
	-- validate that the student exists
	Validate_Student (
		p_snum, --sent
		v_error_text); --recieved
	v_error_msg := v_error_text;
	
	-- make sure the callnumber is valid
	Validate_Callnumber (
		p_callnum, --sent
		v_error_text); --recieved
	v_error_msg := v_error_msg||v_error_text;
	
	-- first check for students and callnumber
	if v_error_msg is not null then
		--dbms_output.put_line (v_error_msg);
		p_ErrorMsg := v_error_msg;
	else
		-- To check for repeat enrollments
		Repeat_Enrollment(
			p_snum, --sent
			p_callnum, --sent
			v_error_text); --recieved
		v_error_msg := v_error_msg||v_error_text;
		
		--to check for double enrollments
		Double_Enrollment(
			p_snum, --sent
			p_callnum, --sent
			v_error_text); --recieved
		v_error_msg := v_error_msg||v_error_text;
		
		-- Make sure student does NOT over 15 units
		Student_Max_Units (
			p_snum, --sent
			p_callnum, --sent
			v_error_text); --recieved
		v_error_msg := v_error_msg||v_error_text;
		
		-- Check for correct standing for classes for student
		Standing_Enrollment(
			p_snum, --sent
			p_callnum, --sent
			v_error_text); --recieved
		v_error_msg := v_error_msg||v_error_text;
		
		-- Check if student is disqualified
		Disqualified_Student(
			p_snum, --sent
			v_error_text); --recieved
		v_error_msg := v_error_msg||v_error_text;
			
		-- second check and check for repeat on waitlist
		if v_error_msg is null then
		
			-- to check capacity
			Open_Class (p_snum, --sent
				p_callnum, --sent
				v_error_text); --recieved
			v_error_msg := v_error_msg||v_error_text;
				
			-- add class if capacity is open, if not, check waitlist
			if v_error_msg is null then
				insert into enrollments values (
					p_snum, p_callnum, null);
				dbms_output.put_line (p_snum || ' You have been successful enrolled in ' || p_callnum);
				p_ErrorMsg := v_error_msg;
			
			else
				-- to make sure student is not already on waitlist
				select count(*) into v_count
				from waitlist
				where snum=p_snum and callnum=p_callnum;
	
				if v_count = 1 then
					v_error_msg := p_snum||', you are already on the waitlist for '|| p_callnum;
					p_ErrorMsg := v_error_msg;
				else
					--to add to waitlist
					insert into Waitlist values (
						p_snum, p_callnum, sysdate);
					v_error_msg := v_error_msg|| 'You are now on the wait list for class number ' ||p_callnum|| '. ';
					p_ErrorMsg := v_error_msg;
				end if;
				
				--dbms_output.put_line (v_error_msg);
				p_ErrorMsg := v_error_msg;
				
			end if;
		
		else
			--dbms_output.put_line (v_error_msg);
			p_ErrorMsg := v_error_msg;
		end if;
	end if;
	commit;
end;

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

-- drop me section

-- check if student is enrolled in the class that is trying to be dropped
procedure Not_Enrolled
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	v_count number(3);
	
begin
	-- to check if student is actually enrolled in the class to drop
	select count(*) into v_count
	from enrollments
	where snum=p_snum and callnum=p_callnum;
	
	if v_count = 1 then
		p_Error_Text:= null;
	else
		p_Error_Text:= p_snum|| ', you are not enrolled in ' ||p_callnum||'. Can not drop. ';
	end if;
	
end;
--------------------------------------------------------------------------------------

-- check to see if grade has already posted
procedure Already_Graded
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	v_sc_capacity number;
	v_e_capacity number;
	v_count number(3);
	
begin
	-- check to see if grade has already posted
	select count(*) into v_count
	from enrollments
	where snum=p_snum and callnum=p_callnum and grade is not null;
	
	if v_count = 1 then
		p_Error_Text:= p_snum|| ', grades have already posted for ' ||p_callnum||'. Can not drop. ';
	else
		p_Error_Text:= null;
	end if;
	
end;
--------------------------------------------------------------------------------------

-- Cursor to check waitlist table and enroll if able to 
procedure Check_Waiting 
	(p_callnum schclasses.callnum%type,
	p_Error_Text out varchar2) as
	p_ErrorMsg varchar2(2000);
	CURSOR wList is
		select snum, callnum, to_char(wldate,'MM/DD/YY HH:MI:SS') wldate
		from waitlist
		where callnum=p_callnum
		order by wldate;
	
begin
	for EachRec in wList loop
		
		Enroll.AddMe (EachRec.snum, EachRec.callnum, p_ErrorMsg); 
	
		if p_ErrorMsg is null then
			delete from waitlist where snum=EachRec.snum and callnum=EachRec.callnum;
			p_Error_Text:= p_ErrorMsg;
			exit when p_ErrorMsg is null;
		else
			p_Error_Text:= p_ErrorMsg;
		end if;
		
	end loop;
	commit;
end;
--------------------------------------------------------------------------------------

-- main procedure to drop a student
procedure DropMe
	(p_snum enrollments.snum%type, p_callnum schclasses.callnum%type ) as
	v_count number;
	v_error_msg varchar2(2000);
	v_error_text varchar2(2000);

begin
	-- validate that the student exists
	Validate_Student (
		p_snum, --sent
		v_error_text); --recieved
	v_error_msg := v_error_text;
	
	-- make sure the callnumber is valid
	Validate_Callnumber (
		p_callnum, --sent
		v_error_text); --recieved
	v_error_msg := v_error_msg||v_error_text;
	
	-- first check for students and callnumber
	if v_error_msg is not null then
		--dbms_output.put_line (v_error_msg);
		dbms_output.put_line (v_error_msg);
	else
		-- check for enrollment in class
		Not_Enrolled (
			p_snum, --sent
			p_callnum, --sent
			v_error_text); --recieved
		v_error_msg := v_error_msg||v_error_text;
		
		-- check if class has already been graded
		Already_Graded (
			p_snum, --sent
			p_callnum, --sent
			v_error_text); --recieved
		v_error_msg := v_error_msg||v_error_text;
	
		if v_error_msg is null then
			update enrollments 
			set grade='W'
			where snum=p_snum and callnum=p_callnum;
			dbms_output.put_line(p_snum||', you have been successfully droped from ' || p_callnum || '. You will recieve a "W"');
		
			
			Check_Waiting (
				p_callnum, --sent
				v_error_text); --recieved
			v_error_msg := v_error_msg||v_error_text;
			dbms_output.put_line (v_error_msg);
		
		else
			--dbms_output.put_line (v_error_msg);
			dbms_output.put_line (v_error_msg);
		end if;
	
	end if;
commit;
end;

end Enroll;
/

-- show compiling errors and pause
show err
pause

spool off

