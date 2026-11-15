# HƯỚNG DẪN THUYẾT TRÌNH / QUAY VIDEO ĐỒ ÁN MIMO (10–15 PHÚT)

> Đây là dàn ý để **nhóm tự thuyết trình**, không phải video/slide có sẵn. Đề bài yêu cầu người trình bày xuất hiện ít nhất ở phần giới thiệu; nếu làm theo nhóm thì mỗi thành viên phải trình bày phần được phân công.

## 1. Dàn ý khoảng 12 phút

| Thời gian | Hình/slide gợi ý | Những điều phải trình bày |
|---|---|---|
| 0:00–1:00 | 1. Tên đề tài và thành viên | Tên đề tài, mục tiêu so sánh ba detector và 3 cấu hình anten |
| 1:00–2:30 | 2. Hệ thống MIMO | Spatial multiplexing: mỗi anten phát luồng BPSK **khác nhau**; khác với diversity |
| 2:30–4:00 | 3. Công thức hệ thống | `Y=HX+Z`, kích thước `Nt x K`, `Nr x Nt`; fading, CSI, `Es/N0`, nhiễu phức |
| 4:00–5:00 | 4. Công thức tách sóng | ZF triệt nhiễu liên luồng; MMSE cân bằng nhiễu; MF phối hợp tín hiệu |
| 5:00–7:30 | 5. MATLAB chạy trực tiếp | Giới thiệu `mimo_parameters`, chạy `demo`, cho thấy command window và thư mục output; nói rõ demo khác full |
| 7:30–10:30 | 6. Kết quả BER, SINR | Đồ thị theo detector/anten, ZF lý thuyết; bảng BER=1e-2 lấy từ kết quả full đã chạy |
| 10:30–12:00 | 7. Kết luận | Các nhận xét có dữ liệu, hạn chế và hướng phát triển |

## 2. Trình diễn MATLAB

**Chuẩn bị trước:** chạy `run_mimo_project('full')` để tạo toàn bộ dữ liệu chính thức. Sau đó trong video chạy `run_mimo_project('demo')` chỉ để minh họa nhanh **nếu cần**. Lưu ý demo sẽ ghi đè các file kết quả cùng tên trong `figures/` và `results/`, vì vậy **sao lưu kết quả full trước khi chạy demo**, hoặc chỉ trình diễn phần code và các hình full đã có. Muốn kết thúc với bộ dữ liệu chính thức, chạy lại full.

Có thể trình diễn cửa sổ Command Window với thông tin cấu hình `4x4`, `4x5`, `4x6`; sau đó mở `Fig_ZF_TheoryValidation.pdf` và `ber_target_snr_summary.csv`. Không cần giả vờ chạy full ngay trong video.

## 3. Những điểm bắt buộc hiểu trước khi nói

1. Tại sao chọn `Nt=4`, `Nr=4,5,6`? Giữ số luồng không đổi, cô lập tác động của số anten thu.
2. Tại sao chọn BPSK? Đơn giản, năng lượng ký hiệu rõ ràng, có công thức BER ZF chính xác để kiểm chứng.
3. `Es/N0` khác SNR tổng như thế nào? Trong chương trình `Es=1` trên **mỗi** luồng và `N0=10^(-SNRdB/10)`.
4. Tại sao có `sqrt(N0/2)` trong mã nhiễu phức? Để mỗi phần thực và ảo có phương sai `N0/2`.
5. Tại sao ZF khuếch đại nhiễu? Khi Gram `H'*H` gần suy biến, nghiệm bình phương tối thiểu có hệ số lớn.
6. Tại sao MMSE có thêm `N0*I`? Đó là nghiệm tối ưu sai số bình phương khi tín hiệu phát có hiệp phương sai `I` và nhiễu `N0*I`.
7. MRC/MF có triệt nhiễu giữa các luồng không? Không. Trong spatial multiplexing, mỗi anten phát dữ liệu khác nhau.
8. `Nr-Nt+1` có ý nghĩa gì? Là bậc phân tập ZF với i.i.d. Rayleigh và CSI hoàn hảo.
9. Một BER mô phỏng bằng 0 nghĩa là gì? Chỉ là chưa quan sát lỗi trong số bit hữu hạn, không phải BER lý thuyết bằng 0.
10. Tại sao phải tạo cùng `bits`, `H`, `Z` cho cả ba detector? Để so sánh công bằng trên cùng mẫu kênh và nhiễu.
11. Tại sao cần nhiều fading blocks? Các lỗi trong một block kênh có thể tương quan; cần nhiều mẫu kênh độc lập để đánh giá BER trung bình.
12. Trường hợp nào lý thuyết ZF không còn chính xác? Sai mô hình Rayleigh i.i.d., CSI không hoàn hảo, điều chế khác/chuẩn hóa khác, hoặc detector không phải ZF.
13. Đường BER được vẽ trên trục tung gì? Thang logarit `semilogy`, không phải tuyến tính.
14. Tại sao đường MRC có thể bão hòa khi SNR tăng? Nhiễu AWGN nhỏ đi nhưng nhiễu giữa các luồng chưa triệt tiêu.
15. Vì sao điểm BER có số lỗi ít cần diễn giải cẩn trọng? Vì ước lượng Monte Carlo có độ không chắc chắn lớn.

## 4. Cách phân công cho nhóm

Nếu ba thành viên, có thể chia thành: (i) tổng quan + mô hình; (ii) ba detector + cài đặt MATLAB; (iii) kết quả + nhận xét/kết luận. Điều chỉnh theo số lượng thành viên thực tế. Mỗi người nên có thể trả lời những câu hỏi cơ bản về toàn bộ mô hình.

## 5. Kiểm tra trước khi quay/nộp

- Video dài 10–15 phút, hình và tiếng rõ; có slide hoặc phương thức minh họa tương đương.
- Người trình bày xuất hiện ít nhất ở giới thiệu; đủ phần trình bày cho mỗi thành viên.
- Đồ thị và số liệu xuất phát từ **full run**, có nhãn `Es/N0`, BER, legend, grid.
- Tên video theo yêu cầu giảng viên, đưa lên YouTube dạng **Unlisted** hoặc nền tảng được phép.
- Kiểm tra liên kết ở chế độ ẩn danh; chèn URL vào bìa báo cáo và README của bộ nộp.
- Cùng tên biến, giả thiết, công thức trong mã nguồn – báo cáo – video.
