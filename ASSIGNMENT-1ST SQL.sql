===========================================================================
---------------------------------DATABASE----------------------------------
===========================================================================

DROP TABLE IF EXISTS ENROLLMENTS CASCADE;
DROP TABLE IF EXISTS INSTRUCTORS CASCADE;
DROP TABLE IF EXISTS COURSES CASCADE;
DROP TABLE IF EXISTS STUDENTS CASCADE;
DROP TABLE IF EXISTS DEPARTMENTS CASCADE;

==========================================================================
-----------------TABLE CREATION-------------------------------------------
==========================================================================

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);

CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    BirthDate DATE,
    EnrollmentDate DATE
);

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    DepartmentID INT,
    Credits INT,
    FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);

CREATE TABLE Instructors (
    InstructorID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    DepartmentID INT,
    FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID)
        REFERENCES Courses(CourseID)
);

==================================================================================
-------------------------------SAMPLE DATA-----------------------------------------
==================================================================================

INSERT INTO Departments (DepartmentID, DepartmentName) VALUES
(1, 'Computer Science'),
(2, 'Mathematics');

INSERT INTO Students
(StudentID, FirstName, LastName, Email, BirthDate, EnrollmentDate) VALUES
(1, 'John',  'Doe',     'john.doe@email.com',       '2000-01-15', '2022-08-01'),
(2, 'Jane',  'Smith',   'jane.smith@email.com',     '1999-05-25', '2021-08-01');

INSERT INTO Courses (CourseID, CourseName, DepartmentID, Credits) VALUES
(101, 'Introduction to SQL', 1, 3),
(102, 'Data Structures',     2, 4);

INSERT INTO Instructors
(InstructorID, FirstName, LastName, Email, DepartmentID) VALUES
(1, 'Alice', 'Johnson', 'alice.johnson@univ.com', 1),
(2, 'Bob',   'Lee',     'bob.lee@univ.com',       2);

INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID, EnrollmentDate) VALUES
(1, 1, 101, '2022-08-01'),
(2, 1, 102, '202-08-02');

ALTER TABLE INSTRUCTORS
ADD COLUMN SALARY NUMERIC (10,2);
INSERT INTO Instructors
(InstructorID, FirstName, LastName, Email, DepartmentID, Salary)VALUES
(1, 'Alice', 'Johnson', 'alice.johnson@univ.com', 1, 70000.00),
(2, 'Bob', 'Lee', 'bob.lee@univ.com', 2, 68000.00);

=================================================================================
--------------------------------Assignment - 1-----------------------------------
==================================================================================

--1. Perform CRUD Operations on all tables.
--Create : Insert a new department
INSERT INTO DEPARTMENTS (DepartmentID, DepartmentName) VALUES
(3, 'Physics');

-- READ: SELECT rows from each table.
SELECT * FROM DEPARTMENTS ORDER BY DEPARTMENTID;
SELECT * FROM COURSES ORDER BY COURSEID;
SELECT * FROM STUDENTS ORDER BY STUDENTID;
SELECT * FROM ENROLLMENTS ORDER BY ENROLLMENTID;
SELECT * FROM INSTRUCTORS ORDER BY INSTRUCTORID;

-- UPDATE example (run if you want to change a record).
UPDATE STUDENTS 
SET EMAIL = 'john.doe@email.com' 
WHERE StudentID = 1;

UPDATE ENROLLMENTS SET ENROLLMENTDATE = '2021-08-01' WHERE ENROLLMENTID = 2;

UPDATE INSTRUCTORS SET SALARY = CASE WHEN INSTRUCTORID =1 THEN 70000.00
WHEN INSTRUCTORID =2 THEN 68000.00 END WHERE INSTRUCTORID IN (1,2);

-- DELETE example (run only when you want to remove a practice row).
-- DELETE FROM DEPARTMENTS
DELETE FROM Departments WHERE DepartmentID = 3;

-- Q2. Retrieve students who enrolled after 2022.
SELECT
*
FROM 
STUDENTS
WHERE ENROLLMENTDATE >= DATE '2023-01-01'
ORDER BY ENROLLMENTDATE;

--3. Retrieve courses offered by the Mathematics department with a limit of 5 courses.
SELECT
C.COURSEID, C.COURSENAME, C.CREDITS, D.DEPARTMENTID
FROM
COURSES C
JOIN DEPARTMENTS D ON D.DEPARTMENTID = C.DEPARTMENTID
ORDER BY C.COURSENAME
LIMIT 5;

-- Q4. Number of students enrolled in each course; show courses with > 5 students.
SELECT c.CourseID, c.CourseName, COUNT(DISTINCT e.StudentID) AS StudentCount
FROM Courses c
JOIN Enrollments e ON e.CourseID = c.CourseID
GROUP BY c.CourseID, c.CourseName
HAVING COUNT(DISTINCT e.StudentID) > 5
ORDER BY StudentCount DESC, c.CourseName;

-- Q5. Students enrolled in BOTH Introduction to SQL and Data Structures.
SELECT s.StudentID, s.FirstName, s.LastName
FROM Students s
JOIN Enrollments e ON e.StudentID = s.StudentID
JOIN Courses c ON c.CourseID = e.CourseID
WHERE c.CourseName IN ('Introduction to SQL', 'Data Structures')
GROUP BY s.StudentID, s.FirstName, s.LastName
HAVING COUNT(DISTINCT c.CourseName) = 2
ORDER BY s.StudentID;

-- Q6. Students enrolled in EITHER Introduction to SQL OR Data Structures (or both).
SELECT DISTINCT s.StudentID, s.FirstName, s.LastName
FROM Students s
JOIN Enrollments e ON e.StudentID = s.StudentID
JOIN Courses c ON c.CourseID = e.CourseID
WHERE c.CourseName IN ('Introduction to SQL', 'Data Structures')
ORDER BY s.StudentID;

-- Q7. Average number of credits across all courses.
SELECT ROUND(AVG(CREDITS)::NUMERIC, 2) AS AVERAGECREDITS
FROM COURSES;

-- Q8. Maximum instructor salary in the Computer Science department.
SELECT MAX(i.Salary) AS MaximumSalary
FROM Instructors i
JOIN Departments d ON d.DepartmentID = i.DepartmentID
WHERE d.DepartmentName = 'Computer Science';

-- Q9. Count students enrolled in each department.
SELECT d.DepartmentID, d.DepartmentName,
       COUNT(DISTINCT e.StudentID) AS EnrolledStudentCount
FROM Departments d
LEFT JOIN Courses c ON c.DepartmentID = d.DepartmentID
LEFT JOIN Enrollments e ON e.CourseID = c.CourseID
GROUP BY d.DepartmentID, d.DepartmentName
ORDER BY d.DepartmentID;


-- Q10. INNER JOIN: students and their corresponding courses.
SELECT s.StudentID, s.FirstName, s.LastName, c.CourseID, c.CourseName, e.EnrollmentDate
FROM Students s
INNER JOIN Enrollments e ON e.StudentID = s.StudentID
INNER JOIN Courses c ON c.CourseID = e.CourseID
ORDER BY s.StudentID, c.CourseID;


-- Q11. LEFT JOIN: all students and their corresponding courses, if any.
SELECT s.StudentID, s.FirstName, s.LastName, c.CourseName, e.EnrollmentDate
FROM Students s
LEFT JOIN Enrollments e ON e.StudentID = s.StudentID
LEFT JOIN Courses c ON c.CourseID = e.CourseID
ORDER BY s.StudentID, c.CourseName;


-- Q12. Subquery: students enrolled in courses with more than 10 students.
SELECT DISTINCT s.StudentID, s.FirstName, s.LastName
FROM Students s
JOIN Enrollments e ON e.StudentID = s.StudentID
WHERE e.CourseID IN (
SELECT e2.CourseID
FROM Enrollments e2
GROUP BY e2.CourseID
HAVING COUNT(DISTINCT e2.StudentID) > 10)
ORDER BY s.StudentID;


-- Q13. Extract the year from each enrollment date.
SELECT EnrollmentID, StudentID, CourseID, EnrollmentDate,
EXTRACT(YEAR FROM EnrollmentDate)::INT AS EnrollmentYear
FROM Enrollments
ORDER BY EnrollmentDate, EnrollmentID;


-- Q14. Concatenate instructor's first and last name.
SELECT InstructorID,
CONCAT(FirstName, ' ', LastName) AS InstructorFullName, Email, DepartmentID
FROM Instructors
ORDER BY InstructorID;


-- Q15. Running total of student enrollments, ordered by enrollment date.
SELECT EnrollmentID, StudentID, CourseID, EnrollmentDate,
COUNT(*) OVER (ORDER BY EnrollmentDate, EnrollmentID
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningEnrollmentTotal
FROM Enrollments
ORDER BY EnrollmentDate, EnrollmentID;


-- Q16. Label students Senior if their student enrollment date is more than 4 years before the current date; otherwise label Junior.
SELECT StudentID, FirstName, LastName, EnrollmentDate,
CASE
WHEN EnrollmentDate < (CURRENT_DATE - INTERVAL '4 years')::DATE
THEN 'Senior'
ELSE 'Junior'
END AS StudentLeve
FROM Students
ORDER BY StudentID;


