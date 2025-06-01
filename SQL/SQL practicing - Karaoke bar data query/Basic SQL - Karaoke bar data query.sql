select * from CHI_TIET_SU_DUNG_DV
select * from dbo.DAT_PHONG
select * from dbo.DICH_VU_DI_KEM
select * from dbo.KHACH_HANG
select * from dbo.PHONG

-- Task 1: List MaDatPhong, MaDV, and SoLuong of all services where the quantity is greater than 3 and less than 10
/*Approach 1*/
select a.MADATPHONG, b.MADV, b.SOLUONG
from DAT_PHONG a join CHI_TIET_SU_DUNG_DV b on a.MaDatPhong = b.MaDatPhong
where b.SoLuong > 3 and  b.SoLuong < 10

/*Approach 2*/
select a.MADATPHONG, b.MADV, b.SOLUONG
from DAT_PHONG a join CHI_TIET_SU_DUNG_DV b on a.MaDatPhong = b.MaDatPhong
where b.SOLUONG between 4 and 9

-- Task 2: Update the GiaPhong field in the PHONG table by increasing it by 10,000 VND compared to the current price, 
/*only for rooms where the maximum number of guests is greater than 10*/

update PHONG
SET GIAPHONG = GIAPHONG + 10000 
where SOKHACHTOIDA > 10

-- Task 3: Delete all bookings (from the DAT_PHONG table) where the booking status (TrangThaiDat) is "Đã hủy". 

DELETE FROM CHI_TIET_SU_DUNG_DV
WHERE MADATPHONG IN (SELECT MADATPHONG FROM DAT_PHONG WHERE TRANGTHAIDAT = 'DA HUY');
DELETE FROM DAT_PHONG
WHERE TRANGTHAIDAT = 'DA HUY';


-- Task 4: Display TenKH of customers whose names start with one of the letters “H”, “N”, or “M” and have a maximum length of 20 characters

/* Approach 1*/
SELECT TENKH
FROM dbo.KHACH_HANG
WHERE (TENKH LIKE 'H%' OR TENKH LIKE 'N%' OR TENKH LIKE 'M%')
  AND LEN(TENKH) <= 20; 

/* Approach 2*/
SELECT TENKH
FROM dbo.KHACH_HANG
WHERE TENKH LIKE '[HNM]%' AND LEN(TENKH) <= 20;

/*Note: Approach 2 is better because of fastter query speed*/

--Task 5: Display TenKH of all customers in the system. If any customer names are duplicated, display each name only once. 
/*Use two different methods to solve this requirement*/

 /*Approach 1*/
SELECT DISTINCT TENKH
FROM dbo.KHACH_HANG

/*Approach 2*/
SELECT TENKH
FROM dbo.KHACH_HANG
GROUP BY TENKH

--Task 6: Display MaDV, TenDV, DonViTinh, and DonGia of accompanying services where DonViTinh is “lon” and DonGia is greater than 10,000 VND, 
/*or where DonViTinh is “Cai” and DonGia is less than 5,000 VND*/

select *
from dbo.DICH_VU_DI_KEM
where (DONVITINH = 'lon' and DONGIA > 10000) or (DONVITINH = 'cai' and DONGIA < 5000)

--Task 7: Display MaDatPhong, MaPhong, LoaiPhong, SoKhachToiDa, GiaPhong, MaKH, TenKH, SoDT, NgayDat, GioBatDau, GioKetThuc, MaDichVu, SoLuong, and DonGia of bookings 
/*where the booking year is "2016" or "2017" and the room price is greater than 50,000 VND per hour.*/

SELECT a.MADATPHONG, 
       a.MAPHONG, 
       b.LOAIPHONG, 
       b.SOKHACHTOIDA, 
       b.GIAPHONG, 
       c.MAKH, 
       c.TENKH, 
       c.SODT, 
       a.NGAYDAT, 
       a.GIOBATDAU, 
       a.GIOKETTHUC, 
       d.MADV, 
       d.SOLUONG, 
       e.DONGIA
FROM dbo.DAT_PHONG a 
JOIN dbo.PHONG b ON a.MAPHONG = b.MAPHONG
JOIN dbo.KHACH_HANG c ON a.MaKH = c.MaKH
JOIN dbo.CHI_TIET_SU_DUNG_DV d ON a.MADATPHONG = d.MADATPHONG
JOIN dbo.DICH_VU_DI_KEM e ON d.MADV = e.MADV
WHERE (YEAR(a.NGAYDAT) = 2016 OR YEAR(a.NGAYDAT) = 2017)
  AND b.GIAPHONG > 50000

  SELECT a.MADATPHONG, 
       a.MAPHONG, 
       b.LOAIPHONG, 
       b.SOKHACHTOIDA, 
       b.GIAPHONG, 
       c.MAKH, 
       c.TENKH, 
       c.SODT, 
       a.NGAYDAT, 
       a.GIOBATDAU, 
       a.GIOKETTHUC, 
       d.MADV, 
       d.SOLUONG, 
       e.DONGIA
FROM dbo.DAT_PHONG a 
left JOIN dbo.PHONG b ON a.MAPHONG = b.MAPHONG
left JOIN dbo.KHACH_HANG c ON a.MaKH = c.MaKH
left JOIN dbo.CHI_TIET_SU_DUNG_DV d ON a.MADATPHONG = d.MADATPHONG
left JOIN dbo.DICH_VU_DI_KEM e ON d.MADV = e.MADV
WHERE (YEAR(a.NGAYDAT) between 2016 and 2017)
  AND b.GIAPHONG > 50000

--Task 8: Display MaDatPhong, MaPhong, LoaiPhong, GiaPhong, TenKH, NgayDat, TongTienHat, TongTienSuDungDichVu, and TongTienThanhToan corresponding to each booking ID in the DAT_PHONG table. 
---Bookings that did not use any accompanying service should still be included.
/*TongTienHat = GiaPhong * (GioKetThuc – GioBatDau)*/
/*TongTienSuDungDichVu = SoLuong * DonGia*/
/*TongTienThanhToan = TongTienHat + sum (TongTienSuDungDichVu)*/

select
	a.MADATPHONG,
	a.MAPHONG,
	b.LOAIPHONG,
	b.GIAPHONG,
	c.TENKH,
	a.NGAYDAT,
	b.GIAPHONG*datediff(hour,a.GIOBATDAU,a.GIOKETTHUC) as TongTienHat,
	d.SOLUONG*e.DONGIA as TongTienSuDungDichVu,
	b.GIAPHONG*datediff(hour,a.GIOBATDAU,a.GIOKETTHUC) + sum(d.SOLUONG*e.DONGIA) as TongTienThanhToan	
from dbo.DAT_PHONG a
join dbo.PHONG b on a.MAPHONG = b.MAPHONG
join dbo.KHACH_HANG c on a.MAKH = c.MAKH
join dbo.CHI_TIET_SU_DUNG_DV d on a.MADATPHONG = d.MADATPHONG
join dbo.DICH_VU_DI_KEM e on d.MADV = e.MADV
group by  
	a.MADATPHONG, a.MAPHONG, b.LOAIPHONG, b.GIAPHONG, c.TENKH, a.NGAYDAT,
    a.GIOBATDAU, a.GIOKETTHUC, d.SOLUONG, e.DONGIA

--Task 9: Display MaKH, TenKH, DiaChi, and SoDT of customers who have previously booked karaoke rooms with an address in "Hoa Xuan".

select  c.MaKH, c.TenKH, c.DiaChi, c.SoDT
from (select a.MaKH, a.TenKH, a.DiaChi, a.SoDT, COUNT(b.MaDatPhong) as LanDatPhong
		from KHACH_HANG a join DAT_PHONG b on a.MAKH = b.MAKH
		group by a.MaKH, a.TenKH, a.DiaChi, a.SoDT) as c
where c.DiaChi = 'Hoa Xuan' and c.LanDatPhong>1

---Task 10: Display MaPhong, LoaiPhong, SoKhachToiDa, GiaPhong, and SoLanDat of rooms that have been booked more than twice by customers and have a booking status of "Đã đặt".

select b.MAPHONG,
	b.LOAIPHONG,
	b.SOKHACHTOIDA,
	b.GIAPHONG,
	COUNT(a.Maphong) as SoLanDat
from dbo.PHONG b join dbo.DAT_PHONG a on b.MAPHONG = a.MAPHONG
where a.TRANGTHAIDAT = 'Da dat'
group by b.MAPHONG, b.LOAIPHONG, b.SOKHACHTOIDA, b.GIAPHONG
having COUNT(a.Maphong)>2









