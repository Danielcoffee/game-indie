-- NOTE:
# Concept Name: Chay lua ngay trong terminal

## Insight — Ý tưởng cốt lõi

## Intuition — Trực giác

## Mental Movie — Bộ phim trong đầu

## Formula — Công thức
$$
$$

## Connection — Liên kết ý tưởng

## Pattern — Mẫu hình lặp lại

## Confusion — Điểm chưa hiểu

## Questions — Câu hỏi mở

## Summary — Tóm tắt bằng lời của mình
..................................................

-- NOTE:
# Concept Name 2: arg talbe

## Insight — quan trong trong CLI tool trong terminal 

## Intuition — Trực giác

## Mental Movie — Bộ phim trong đầu

## Formula — Công thức
$$
lua file.lua a b c
$$

## Connection — Liên kết ý tưởng

## Pattern — Mẫu hình lặp lại

## Confusion — Điểm chưa hiểu

## Questions — Câu hỏi mở

## Summary — Tóm tắt bằng lời của mình
- o day file.lua = arg[0]
- lua = arg[-1]
- a = arg[1]
- print(...): se ra tat ca cac arg trong do

-- NOTE:
# Concept Name 1: Chay lua ngay trong terminal

## Insight — Ý tưởng cốt lõi
- Khong can vao interactive mode van chay duoc lua ngay trong terminal

## Intuition — Trực giác: ngan gon

## Mental Movie — Bộ phim trong đầu
- co ket qua ngay

## Formula — Công thức
$$
lua -e "print(math.sin(3))" -- chay lua ngay trong terminal
$$

## Connection — Liên kết ý tưởng

## Pattern — Mẫu hình lặp lại

## Confusion — Điểm chưa hiểu

## Questions — Câu hỏi mở

## Summary — Tóm tắt bằng lời của mình: can thiet khi debugging
-- TODO:
-- FIXME:
# Lua programming

## chapter 1
- chunk moi phan cua lua
- nho ham doc number khi goi tren man hinh
print("insert gia tri")
a = io.read("*n") -- doc gia tri so khi insert vao man hinh

- su dung lua -i prog.lua voi tham so "-i" de debugging (vi se vao lua interactive va cho doi)
- co the su dung dofile("prog.lua") trong interactive mode
- Sau do co the su dung & test cac thanh phan mong muon
- if x then...
+ van de la moi thu deu true tru khi x == nil hoac x == false
khi viet i ~= 0 la de chi i khac 0. hay dung khi lam guard condition
*Lua chi muon cong tac voi C*



