-- Phần 1: DDL - Thiết kế cơ sở dữ liệu

create database qldb;
use qldb;

create table football_teams (
	team_id int primary key auto_increment,
    team_name varchar(100) not null,
    team_code varchar(20) not null unique,
    home_area  varchar(100) not null,
    founded_date date not null
);

create table players (
	player_id int primary key auto_increment,
    full_name varchar(100) not null,
    preferred_position varchar(30) check (preferred_position in ('Thủ môn', 'Hậu vệ', 'Tiền vệ', 'Tiền đạo')),
    phone_number varchar(15) not null unique,
    skill_rating decimal(3,1) default 5.0 check (skill_rating between 0.0 and 10.0)
);

create table matches (
	match_id int primary key auto_increment,
    team_id int,
    opponent_name varchar(100) not null,
    venue varchar(150) not null,
    match_time datetime not null,
    pitch_fee decimal(10,2) check (pitch_fee >= 0),
    status varchar(30) check (status in ('Scheduled', 'Completed', 'Cancelled')),
    foreign key (team_id) references football_teams (team_id)
    on update cascade on delete restrict
);

create table match_registrations (
	registration_id int primary key auto_increment,
    match_id int,
    player_id int,
    attendance_status varchar(30) check (attendance_status in ('Registered', 'Played', 'Absent')),
    goals int default 0 check (goals >= 0),
    registered_at datetime default current_timestamp,
    foreign key (match_id) references matches (match_id)
    on update cascade on delete restrict,
    foreign key (player_id) references players (player_id)
    on update cascade on delete restrict,
    unique (match_id, player_id)
);

create table team_logs (
	log_id int primary key auto_increment,
    registration_id int,
    player_id int,
    log_time datetime not null,
    note text not null,
	foreign key (registration_id) references match_registrations (registration_id)
    on update cascade on delete restrict,
    foreign key (player_id) references players (player_id)
    on update cascade on delete restrict
);

-- Phần 2. DML - insert, update, delete
-- Câu 1 - insert
-- insert dữ liệu bảng football_teams
insert into football_teams (team_id, team_name, team_code, home_area, founded_date)
values 
(1, 'Sài Gòn Strikers', 'SGS', 'Quận 1', '2018-03-10'),
(2, 'Thunder FC', 'TFC', 'TP Thủ Đức', '2021-06-15'),
(3, 'Brother United', 'BRU', 'Bình Thạnh', '2016-09-20'),
(4, 'Weekend Warriors', 'WKW', 'Quận 7', '2022-01-08'),
(5, 'Office Eleven', '011', 'Gò Vấp', '2019-11-30');

-- insert dữ liệu bảng players
insert into players (player_id, full_name, preferred_position, phone_number, skill_rating)
values 
(1, 'Nguyễn Minh Khang', 'Tiền đạo', '901112233', 8.2),
(2, 'Trần Hoàng Nam', 'Tiền vệ', '902223344', 7.5),
(3, 'Lê Quốc Huy', 'Hậu vệ', '903334455', 7.8),
(4, 'Phạm Gia Bảo', 'Thủ môn', '904445566', 8.2),
(5, 'Võ Thành Công', 'Tiền vệ', '905556677', 7.0);

-- insert dữ liệu bảng matches
insert into matches (match_id, team_id, opponent_name, venue, match_time, pitch_fee, status)
values
(7001, 1, 'Black Cats', 'Sân Tao Đàn', '2026-05-20 18:00:00', '1200000', 'Scheduled'),
(7002, 3, 'Blue Sharks', 'Sân Gia Định', '2026-05-21 19:30:00', '1500000', 'Completed'),
(7003, 2, 'Bình Minh FC', 'Sân Linh Trung', '2026-05-22 18:30:00', '1000000', 'Completed'),
(7004, 5,  'Red Bulls', 'Sân Kỳ Hòa', '2026-05-23 20:00:00', '1300000', 'Cancelled'),
(7005, 4,  'Young Boys', 'Sân Hoàng Văn Thụ', '2026-05-24 17:30:00', '1100000', 'Scheduled');

-- insert dữ liệu bảng match_registrations
insert into match_registrations (registration_id, match_id, player_id, attendance_status, goals, registered_at)
values
(8001, 7002, 1, 'Played', 2, '2026-05-19 09:00:00'),
(8002, 7002, 3, 'Played', 0, '2026-05-19 09:15:00'),
(8003, 7001, 2,  'Registered', 0, '2026-05-18 20:00:00'),
(8004, 7003, 5,  'Played', 1, '2026-05-20 08:30:00'),
(8005, 7004, 4, 'Absent', 0, '2026-05-21 10:00:00');

-- insert dữ liệu bảng team_logs
insert into team_logs (log_id, registration_id, player_id, log_time, note)
values
(1, 8003, 2, '2026-05-18 20:05:00', 'Xác nhận tham gia trận'),
(2, 8001, 1, '2026-05-19 09:05:00', 'Đăng ký đá chính'),
(3, 8002, 3, '2026-05-19 09:20:00', 'Xác nhận tham gia'),
(4, 8004, 5, '2026-05-20 08:35:00', 'Đã có mặt tại sân'),
(5, 8005, 4, '2026-05-23 20:05:00', 'Vắng mặt không báo trước');

-- Câu 2: Update & delete
-- 1. tăng pitch_fee thêm 100.000 cho các trận có status là "Completed'
update matches
set pitch_fee = pitch_fee + 100000
where status = 'Completed';

-- 2. xóa các bản ghi trong team-logs có log_time < 2026-05-20
delete from team_logs
where log_time < '2026-05-20 00:00:00';

-- Phần 3: Truy vấn cơ bản
-- Câu 1: liệt kê full_name, preferred_position, skill_rating của các cầu thủ có skill_rating > 7.8 hoặc preferred_position = 'Tiền vệ'
select full_name, preferred_position, skill_rating
from players
where skill_rating > 7.8 or preferred_position = 'Tiền vệ';

-- Câu 2: liệt kê opponent_name, venue, match_time của các trận diễn ra từ 2026-05-20 đến hết ngày 2026-05-22 và opponent_name like 'B%'
select opponent_name, venue, match_time
from matches
where date(match_time) between '2026-05-20' and '2026-05-22'
and opponent_name like 'B%';

-- Câu 3: liệt kê registration_id, goals, registered_at:
-- goals desc
-- goals bằng nhau thì registration_id asc
-- limit 2 offset 2
select registration_id, goals, registered_at
from match_registrations
order by goals desc, registration_id asc
limit 2 offset 2;

-- Phần 4: Truy vấn nâng cao
-- Câu 1: liệt kê: team_name (football_teams), opponent_name (matches), full_name (players), preferred_position (players), 
-- goals (match_registrations), match_time (matches)
select 
	ft.team_name,
    m.opponent_name,
    p.full_name,
    p.preferred_position,
    mr.goals,
    m.match_time
from match_registrations mr
join matches m 
on mr.match_id = m.match_id
join football_teams ft 
on m.team_id = ft.team_id
join players p 
on mr.player_id = p.player_id;

-- Câu 2: liệt kê full_name (players), total_goals (match_registrations) mà attendance_status(match_registrations) = 'Played'
-- total_goals > 1
select 
	p.full_name,
    SUM(mr.goals) as total_goals
from players p
join match_registrations mr 
on p.player_id=mr.player_id
where mr.attendance_status = 'Played'
group by p.player_id, p.full_name
having total_goals > 1;

-- Câu 3: liệt kê player_id, full_name, skill_rating của cầu thủ có skill_rating MAX. 
select player_id, full_name, skill_rating
from players
where skill_rating = (select max(skill_rating) from players);

-- Phần 5: Index & view
-- Câu 1: tạo index trên bảng match_registrations gồm attendance_status và goals
create index idx_match_status_goals
on match_registrations (attendance_status, goals);

-- Câu 2: tạo view hiển thị: player_id, full_name, total_matches, total_goals
create view v_player_match_info as
select 
	p.player_id,
    p.full_name,
    count(mr.registration_id) as total_matches,
    case 
		when 
			sum(mr.goals) is null then 0
        else
			sum(mr.goals)
	end as total_goals
from players p
join match_registrations mr
on p.player_id = mr.player_id
where attendance_status != 'Absent'
group by p.player_id, p.full_name;

-- kiểm tra view
select * from v_player_match_info;

-- Phần 6: Trigger
-- Câu 1: Trigger sau khi update match_registrations
-- attendance_status update sang 'Played' => tự động insert into team_logs

delimiter $$

create trigger trg_after_update_match_registrations
after update on match_registrations
for each row
begin
	if new.attendance_status = 'Played' and old.attendance_status != 'Played' then
		insert into team_logs (registration_id, player_id, note, log_time)
		values (new.registration_id, new.player_id, 'Player confirmed as played', now());
    end if;
end $$

delimiter ;

-- Câu 2: Viết trigger after insert vào match_registrations
-- nếu attendance_status = 'Played' thì skill_rating(players) thêm 0.1
-- skill_rating <=10.0

delimiter $$

create trigger trg_after_insert_match_registrations
after insert on match_registrations
for each row
begin 
	if new.attendance_status = 'Played' then
		update players
        set skill_rating = if(skill_rating + 0.1 > 10.0, 10.0, skill_rating + 0.1)
        where player_id = new.player_id;
	end if;
end $$

delimiter ;

-- Phần 7: Stored procedure
-- Câu 1: Viết procedure với in = player_id, trả về message
-- total_goals > 3 'Top scorer'
-- total_goals = 3 'Target met'
-- else 'Keep training'
-- chưa thi đấu, chưa ghi bàn thì 0

delimiter $$

create procedure sp_get_player_performance (
	in p_player_id int
)
begin
	declare total_goals int default 0;
    -- tính tổng số bàn thắng 
    select sum(goals) into total_goals
    from match_registrations
    where player_id = p_player_id
    and attendance_status = 'Played';
    
    -- điều kiện
    if total_goals > 3 then
		select 'Top scorer' as message;
	elseif total_goals = 3 then
		select 'Target met' as message;
	else
		select 'Keep training' as message;
	end if;
end $$

delimiter ;

-- kiểm tra procedure
call sp_get_player_performance (2);

-- Câu 2: Viết procedure chuyển lượt đăng ký thi đấu sang cầu thủ khác
-- IN: registration_id, new_player_id

delimiter $$

create procedure sp_reassign_player (
	in p_registration_id int,
    in p_new_player_id int
)
begin
	-- 5. Nếu có lỗi thì rollback bằng exit handler
	declare exit handler for sqlexception
    begin
		rollback;
	end;
	
    -- 1. Bắt đầu transaction
    start transaction;
    
    -- 2. Cập nhật player_id mới trong match_registrations
    update match_registrations
    set player_id = p_new_player_id
    where registration_id = p_registration_id;
    
    -- 3. Thêm bản ghi vào team_logs
    insert into team_logs (registration_id, player_id, note, log_time)
    values (p_registration_id, p_new_player_id, 'Player reassigned', now());
    
    -- 4. Xác nhận thành công
    commit;
end $$

delimiter ;    
    
    