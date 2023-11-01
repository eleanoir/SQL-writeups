-------------------
--CURSORS ANSWERS--
-------------------

SET SERVEROUTPUT ON
SET VERIFY OFF
	
------------
--QUESTION 1
------------
DECLARE
	CURSOR EMPCUR IS
		SELECT LNAME, FNAME, SALARY, HIREDATE FROM EMPLOYEE;
	LAST EMPLOYEE.LNAME%TYPE;
	FIRST EMPLOYEE.FNAME%TYPE;
	SAL EMPLOYEE.SALARY%TYPE;
	HIRE EMPLOYEE.HIREDATE%TYPE;
BEGIN
	OPEN EMPCUR;
	FETCH EMPCUR INTO LAST, FIRST, SAL, HIRE;  
	WHILE EMPCUR%FOUND LOOP
		IF SAL > 50000 AND HIRE < TO_DATE('31-12-2012', 'DD-MM-YYYY') THEN
			DBMS_OUTPUT.PUT_LINE(LAST || ', ' || FIRST || ' makes $' || SAL);
			DBMS_OUTPUT.PUT_LINE('Hired on '|| TO_CHAR(HIRE, 'DD-MM-YYYY'));
			DBMS_OUTPUT.PUT_LINE('');
		END IF;
		FETCH EMPCUR INTO LAST, FIRST, SAL, HIRE;
	END LOOP;
	CLOSE EMPCUR;
END;

--QUESTION 2
------------
DECLARE
	CURSOR EMPCUR(SAL EMPLOYEE.SALARY%TYPE) IS
		SELECT LNAME, FNAME, SALARY FROM EMPLOYEE WHERE SALARY > SAL;
	EMPREC EMPCUR%ROWTYPE;
	SAL EMPLOYEE.SALARY%TYPE := &S_SALARY;
BEGIN
	OPEN EMPCUR(SAL);
	FETCH EMPCUR INTO EMPREC.LNAME, EMPREC.FNAME, EMPREC.SALARY;
	WHILE EMPCUR%FOUND LOOP
		DBMS_OUTPUT.PUT_LINE(EMPREC.LNAME|| ', ' || EMPREC.FNAME || ' makes $' || EMPREC.SALARY);
		FETCH EMPCUR INTO EMPREC.LNAME, EMPREC.FNAME, EMPREC.SALARY;
	END LOOP;
	CLOSE EMPCUR;
END;

--QUESTION 3
------------
DECLARE
	CURSOR EMPCUR IS
		SELECT EMPLOYEEID, SALARY FROM EMPLOYEE WHERE DEPTID = 10 FOR UPDATE;
	INCR NUMBER;
	NEW_SALARY EMPLOYEE.SALARY%TYPE;
BEGIN
	FOR EMPREC IN EMPCUR LOOP
		IF EMPREC.SALARY < 100000 THEN
			INCR := 0.15;
		ELSE 
			INCR := 0.10;
		END IF;
		DBMS_OUTPUT.PUT_LINE('Updating salary for employee ' || EMPREC.EMPLOYEEID);
		DBMS_OUTPUT.PUT_LINE('Old salary: ' || EMPREC.SALARY);
		UPDATE EMPLOYEE SET SALARY = SALARY + SALARY * INCR WHERE CURRENT OF EMPCUR;
		SELECT SALARY INTO NEW_SALARY FROM EMPLOYEE WHERE EMPLOYEEID = EMPREC.EMPLOYEEID;
		DBMS_OUTPUT.PUT_LINE('Updated salary: ' || NEW_SALARY);
		DBMS_OUTPUT.PUT_LINE('Increased by: ' || (INCR+1));
		DBMS_OUTPUT.PUT_LINE('---');
	END LOOP;
END;

--QUESTION 4
------------
DECLARE
	LAST EMPLOYEE.LNAME%TYPE;
	FIRST EMPLOYEE.FNAME%TYPE;
	DEPT EMPLOYEE.DEPTID%TYPE;
	QUAL EMPLOYEE.QUALID%TYPE := &S_QUALID;
BEGIN
	SELECT LNAME, FNAME, DEPTID 
	INTO LAST, FIRST, DEPT
	FROM EMPLOYEE WHERE QUALID = QUAL;
	
	DBMS_OUTPUT.PUT_LINE(LAST || ', ' || FIRST||' works for department ' || DEPT);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('No employee found with such qualification.');
	WHEN TOO_MANY_ROWS THEN
		DBMS_OUTPUT.PUT_LINE('More than one employee found.');
END;
