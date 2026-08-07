-- PHẦN 1: DDL ‒ THIẾT KẾ CSDL (15 ĐIỂM)
create database qlhv;
create table courses (
 course_id INT primary key,
 course_name VARCHAR(100) not null,
 course_code VARCHAR(20) not null unique,
 department VARCHAR(100) not null,
 creation_date DATE
 );
 
 Delimiter $$
 create trigger tg_check_creation_date
 before insert on courses
 for each row
 begin
  IF new.creation_date > current_date() then
	signal sqlstate '45000'
	SET message_text = 'Creation date must be before today';
  END IF;
END$$
Delimiter ;

create table students (
student_id INT primary key,
full_name VARCHAR(100) not null,
major VARCHAR(100) not null,
phone_number VARCHAR(15) not null unique,
gpa DECIMAL(3,1) default 4.0 Check (gpa between 0.0 and 4.0)
);

create table enrollments (
enrollment_id INT primary key,
course_id INT, 
foreign key (course_id) references courses (course_id),
student_id INT,
foreign key (student_id) references students (student_id),
enroll_time DATETIME not null,
credits INT Check (credits > 0),
status VARCHAR(50) 
Check (status IN ('Pending', 'Completed', 'Dropped'))
);

create table enrollment_details (
detail_id INT primary key,
enrollment_id INT,
foreign key (enrollment_id) references enrollments (enrollment_id),
attendance_check VARCHAR(150) not null,
detail_date DATETIME 
default current_timestamp
);

create table academic_logs (
log_id INT primary key,
enrollment_id INT,
foreign key (enrollment_id) references enrollments (enrollment_id),
student_id INT,
foreign key (student_id) references students (student_id),
log_time DATETIME not null,
note TEXT
);

-- PHẦN 2: DML ‒ INSERT, UPDATE, DELETE (25 ĐIỂM)
-- Câu 1 ‒ INSERT (15 điểm)
insert into courses (course_id, course_name, course_code, department, creation_date)
values 
(1, 'Lập trình Java', 'JAVA01', 'CNTT', '2023-12-03'),
(2, 'Cấu trúc dữ liệu', 'DSA02', 'Khoa học máy tính', '1996-11-25'),
(3, 'Cơ sở dữ liệu', 'SQL03', 'CNTT', '2001-07-08'),
(4, 'Mạng máy tính', 'NET04', 'Truyền thông', '1998-01-19'),
(5, 'Trí tuệ nhân tạo', 'AI05', 'Khoa học máy tính', '2000-09-30');

insert into students (student_id, full_name, major, phone_number, gpa)
values
(1, 'Nguyễn Văn Hải', 'Hệ thống TT', '0931112223', 3.8),
(2, 'Trần Thu Hà', 'Kỹ thuật PM', '0932223334', 4.0),
(3, 'Lê Quốc Tuấn', 'An toàn TT', '0933334445', 3.6),
(4, 'Phạm Minh Châu', 'Dữ liệu lớn', '0934445556', 3.9),
(5, 'Hoàng Gia Bảo', 'Kỹ thuật PM', '0935556667', 3.7);

insert into enrollments (enrollment_id, course_id, student_id, enroll_time, credits, status)
values 
(7001, 1, 1, '2024-05-20 08:00', 3, 'Pending'),
(7002, 2, 2, '2024-05-20 09:30', 4, 'Completed'),
(7003, 3, 3, '2024-05-20 10:15', 3, 'Pending'),
(7004, 4, 5, '2024-05-21 07:00', 3, 'Completed'),
(7005, 5, 4, '2024-05-21 08:45', 4, 'Dropped');

insert into enrollment_details (detail_id, enrollment_id, attendance_check, detail_date)
values 
(8001, 7002, 'Đủ điều kiện thi', '2024-05-20 10:00'),
(8002, 7004, 'Vắng 1 buổi', '2024-05-21 08:00'),
(8003, 7001, 'Đang học', '2024-05-20 09:00'),
(8004, 7003, 'Nghỉ phép', '2024-05-20 11:00'),
(8005, 7005, 'Không đi học', '2024-05-21 09:00');

insert into academic_logs (log_id, enrollment_id, student_id, log_time, note)
values
(1, 7001, 1, '2024-05-20 09:05', 'Bắt đầu lớp học'),
(2, 7002, 2, '2024-05-20 10:05', 'Hoàn tất môn học'),
(3, 7003, 3, '2024-05-20 11:10', 'Đang sắp xếp lịch bù'),
(4, 7004, 5, '2024-05-21 08:10', 'Chờ phê duyệt điểm'),
(5, 7005, 4, '2024-05-21 09:05', 'Hủy do vắng quá số buổi');

-- Câu 2 ‒ UPDATE & DELETE (10 điểm)
update enrollments e
join courses c
on e.course_id = c.course_id
SET e.credits = e.credits + 1
Where e.status = 'Completed' and year(c.creation_date) < 2000;

delete from academic_logs
where log_time < '2024-05-20';

-- PHẦN 3: TRUY VẤN CƠ BẢN (15 ĐIỂM)
-- Câu 1 (5 điểm): Liệt kê các thông tin sinh viên gồm full_name, major và gpa của những sinh viên có điểm GPA lớn hơn 3.8 hoặc thuộc chuyên ngành “Kỹ thuật PM”.
Select full_name, major, gpa
from students
where gpa > 3.8 and major = 'Kỹ thuật PM';

-- Câu 2 (5 điểm): Liệt kê các thông tin môn học gồm course_name và course_code của những
-- môn học có ngày tạo trong khoảng từ 1998-01-01 đến 2001-12-31 và mã học phần bắt đầu bằng “A”.
Select course_name, course_code
from courses
where creation_date between '1998-01-01' and '2001-12-31'
AND course_code like 'A%';

-- Câu 3 (5 điểm): Liệt kê các bản ghi đăng ký học gồm enrollment_id, enroll_time và credits,
-- trong đó danh sách được sắp xếp theo số tín chỉ (credits) giảm dần và chỉ hiển thị 2 bản ghi ở trang thứ hai.
select enrollment_id, enroll_time, credits
from enrollments
order by credits desc
limit 2 offset 2;

-- PHẦN 4: TRUY VẤN NÂNG CAO (15 ĐIỂM)
-- Câu 1 (5 điểm): Liệt kê các thông tin xử lý học vụ gồm tên môn học, họ tên sinh viên, chuyên
-- ngành, số tín chỉ và thời gian đăng ký, với dữ liệu được lấy từ các bảng liên quan trong hệ thống.
select 
c.course_name,
s.full_name,
s.major,
e.credits,
e.enroll_time
from enrollments e
join students s
on e.student_id = s.student_id
join courses c
on e.course_id = c.course_id;

-- Câu 2 (5 điểm): Liệt kê các thông tin sinh viên gồm họ tên sinh viên và tổng số tín chỉ mà sinh
-- viên đó đã tích lũy (chỉ tính các đăng ký trạng thái Completed), chỉ hiển thị những sinh viên có
-- tổng số tín chỉ lớn hơn 120.
select
s.full_name,
SUM(e.credits) AS total_credits
from students s
join enrollments e
on s.student_id = e.student_id
where e.status = 'Completed'
Group by s.student_id, s.full_name
having SUM(e.credits) > 120;

-- Câu 3 (5 điểm): Liệt kê các thông tin sinh viên gồm student_id, full_name và gpa của những sinh
-- viên có điểm trung bình (GPA) cao nhất.
select
student_id,
full_name,
gpa
from students s
where gpa = (select MAX(gpa) from students);

-- PHẦN 5: INDEX & VIEW (10 ĐIỂM)
-- Câu 1 (5 điểm): Tạo một chỉ mục (index) trên bảng enrollments dựa trên hai thông tin là trạng
-- thái học và số tín chỉ nhằm phục vụ việc tối ưu truy vấn.
create index id_status_credits
on enrollments (status, credits);

-- Câu 2 (5 điểm): Tạo một khung nhìn (view) dữ liệu hiển thị họ tên sinh viên, tổng số môn học đã
-- đăng ký và tổng số tín chỉ mà sinh viên đó đã tích lũy, trong đó không tính các môn bị hủy (Dropped).
create view v_student_totalcourses_totalcredits
as
select 
s.full_name,
count(e.course_id) AS total_courses,
SUM(e.credits) AS total_credits
FROM students s
JOIN enrollments e
    ON s.student_id = e.student_id
where e.status != 'Dropped'
Group by s.student_id, s.full_name;

SELECT *
FROM v_student_totalcourses_totalcredits;

-- PHẦN 6: TRIGGER (10 ĐIỂM)
-- Câu 1 (5 điểm): 
Delimiter $$
create trigger tg_enrollments_academic_logs
after update on enrollments
for each row
begin
	IF new.status = 'Completed' then
		insert into academic_logs (enrollment_id, student_id, log_time, note)
		values (new.enrollment_id, new.student_id, now(), 'Course completed');
	end if;
END $$
Delimiter ;

-- Câu 2 (5 điểm): 
Delimiter $$
create trigger tg_update_enrollments_gpa
after insert on enrollments
for each row
begin
	IF new.status = 'Completed' then
		update students 
        SET gpa = IF(gpa + 0.1 > 4.0, 4.0, gpa + 0.1)
        WHERE student_id = new.student_id;
	end if;
END $$
Delimiter ;

-- PHẦN 7: STORED PROCEDURE (10 ĐIỂM)
-- Câu 1 (5 điểm): Viết một stored procedure nhận vào mã sinh viên và trả về một thông báo kết
-- quả, trong đó:
-- • Nếu tổng số tín chỉ Completed của sinh viên > 100 thì trả về 'Excellent progress'.
-- • Nếu bằng 100 thì trả về 'Target met'.
-- • Nếu nhỏ hơn 100 thì trả về 'Normal progress'.
Delimiter $$
create procedure p_students_result (
	IN p_student_id int)
begin
	DECLARE total_credits INT;
    -- Tính tổng tín chỉ Completed
	SELECT SUM(credits)
    INTO total_credits
    FROM enrollments
    WHERE student_id = p_student_id
    AND status = 'Completed';

    -- Kiểm tra kết quả
    IF total_credits > 100 THEN
        SELECT 'Excellent progress' AS result;
    ELSEIF total_credits = 100 THEN
        SELECT 'Target met' AS result;
    ELSE
        SELECT 'Normal progress' AS result;
	end if;
END $$
Delimiter ;
Call p_students_result (1);

-- Câu 2 (5 điểm): 
Delimiter $$
create procedure p_reassign_student (
	IN p_enrollment_id INT,
    IN p_new_student_id INT
)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Bước 2: Đổi sinh viên trong bảng enrollments
    UPDATE enrollments
    SET student_id = p_new_student_id
    WHERE enrollment_id = p_enrollment_id;

    -- Bước 3: Ghi log
    INSERT INTO academic_logs (enrollment_id, student_id, note, log_time)
    VALUES(p_enrollment_id, p_new_student_id, 'Student reassigned', NOW());

    -- Bước 5: Hoàn tất
    COMMIT;

END $$
DELIMITER ;