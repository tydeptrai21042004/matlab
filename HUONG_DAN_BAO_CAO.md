# HƯỚNG DẪN VIẾT BÁO CÁO ĐỒ ÁN MIMO SPATIAL MULTIPLEXING

> Tài liệu hướng dẫn, **không phải báo cáo hoàn chỉnh**. Mọi hình và số liệu phải lấy từ kết quả MATLAB mà nhóm tự chạy. Đề bài khuyến nghị 15–25 trang (không tính phụ lục).

## 1. Quy ước và các lựa chọn thiết kế

| Thành phần | Quy ước sử dụng trong chương trình | Lý do |
|---|---|---|
| Kỹ thuật | Spatial multiplexing | Các anten truyền đồng thời luồng dữ liệu **khác nhau** |
| Cấu hình | `4x4`, `4x5`, `4x6` | Giữ `Nt=4`, khảo sát ảnh hưởng tăng số anten thu `Nr>=Nt` |
| Điều chế | BPSK, `0 -> -1`, `1 -> +1` | BER có lý thuyết kiểm chứng trực tiếp |
| Công suất | `Es=1` trên **mỗi** anten phát; tổng công suất trung bình `Nt=4` | Không thay đổi tổng công suất khi chỉ đổi `Nr` |
| Kênh | Fading phẳng, block Rayleigh, `H_ij ~ CN(0,1)` | Mô hình MIMO cơ sở có lời giải BER ZF |
| Nhiễu | `z ~ CN(0,N0 I)` | Các anten thu chịu AWGN độc lập |
| CSI | Máy thu biết `H` hoàn hảo | Tập trung so sánh thuật toán tách sóng |
| Trục hoành | `Es/N0` **trên mỗi luồng**, tính bằng dB | Được định nghĩa chính xác trong công thức mô phỏng |

Ở mỗi thời điểm ký hiệu:

\[
\mathbf y=\mathbf H\mathbf x+\mathbf z,\quad
\mathbf H\in\mathbb C^{N_r\times N_t},\quad
\mathbf x\in\{-1,+1\}^{N_t},\quad
\mathbf z\sim\mathcal{CN}(\mathbf0,N_0\mathbf I_{N_r}).
\]

Với một khối gồm `K` thời điểm ký hiệu, ta dùng `Y = H*X + Z`, trong đó `X` kích thước `Nt x K`. `H` giữ không đổi trong một khối và độc lập giữa các khối. Mỗi khối là một lần lấy mẫu fading độc lập.

Trong chương trình:

\[
E_s=\mathbb{E}[|x_i|^2]=1,\quad
\gamma_s=E_s/N_0=10^{S_{\rm dB}/10},\quad
N_0=10^{-S_{\rm dB}/10}.
\]

Nhiễu MATLAB được tạo bởi

```matlab
Z = sqrt(N0/2)*(randn(Nr,K) + 1i*randn(Nr,K));
```

Hệ số `sqrt(N0/2)` quan trọng vì phần thực và phần ảo đều có phương sai `N0/2`. Không nhầm `Es/N0` với `Eb/N0` hoặc với công suất tổng phát. Với BPSK một bit trên một ký hiệu, `Es=Eb` **trên mỗi luồng**, song quy ước vẫn phải ghi rõ.

## 2. Các bộ tách sóng tuyến tính

Đặt `W` là ma trận tách sóng có kích thước `Nt x Nr` và `xHat = W*y`.

### Zero Forcing (ZF)

Từ bài toán bình phương tối thiểu `min_x ||y-Hx||_2^2`, nếu `Nr>=Nt` và `H` hạng cột đầy đủ:

\[
\widehat{\mathbf x}_{ZF}=\mathbf W_{ZF}\mathbf y,\qquad
\mathbf W_{ZF}=(\mathbf H^H\mathbf H)^{-1}\mathbf H^H.
\]

ZF triệt tiêu nhiễu giữa các luồng vì `W_ZF*H = I`. Tuy nhiên, ở kênh gần suy biến, ZF có thể khuếch đại nhiễu AWGN. Trong mã nguồn dùng toán tử `\` (giải hệ) thay cho phép nhân với `inv(...)`.

### Minimum Mean Square Error (MMSE)

Đối với `E[xx^H]=I` và `E[zz^H]=N0 I`, chọn `W` tối thiểu hóa `E[||x-Wy||_2^2]`. Kết quả:

\[
\mathbf W_{MMSE}=(\mathbf H^H\mathbf H+N_0\mathbf I_{N_t})^{-1}\mathbf H^H.
\]

MMSE đánh đổi giữa triệt nhiễu liên luồng và khuếch đại nhiễu. Khi `N0 -> 0` và `H` hạng cột đầy đủ thì `W_MMSE -> W_ZF`.

### Maximum Ratio Combining / Matched Filter (MRC/MF)

Trong bài toán **nhiều luồng cùng phát**, bộ lọc phối hợp là

\[
\mathbf W_{MF}=\mathbf H^H,
\]

hoặc chuẩn hóa hàng `i` thành `h_i^H/||h_i||^2`, như chương trình. Vì mỗi luồng BPSK được quyết định theo dấu phần thực, hệ số chuẩn hóa dương không đổi bit phát hiện. MRC/MF không tự triệt nhiễu giữa các luồng, do đó **có thể xuất hiện error floor** khi SNR tăng và `Nr` chưa đủ lớn.

### SINR của một bộ tách sóng bất kỳ

Đặt `A=W*H`. Với tín hiệu phát độc lập, năng lượng mỗi luồng bằng 1, SINR đầu ra của luồng `i` là

\[
\mathrm{SINR}_i=\frac{|A_{ii}|^2}
{\sum_{j\ne i}|A_{ij}|^2+N_0\sum_{k=1}^{N_r}|W_{ik}|^2}.
\]

`mimo_post_sinr.m` thực hiện **đúng mẫu số gồm nhiễu liên luồng và nhiễu máy thu**. Các cột `MeanSINR_*_dB` trong CSV là trung bình của SINR đã đổi sang dB theo các luồng và các khối fading, không phải `10log10` của SINR tuyến tính trung bình.

## 3. Lý thuyết BER dùng để kiểm chứng

Đối với ZF, BPSK, kênh Rayleigh độc lập và hoàn hảo CSI, SNR đầu ra mỗi luồng có phân bố Gamma với bậc phân tập

\[
d=N_r-N_t+1.
\]

BER trung bình được tính chính xác bởi

\[
\overline P_{b,ZF}=\frac1\pi\int_0^{\pi/2}
\left(1+\frac{\gamma_s}{\sin^2\theta}\right)^{-d}\,d\theta.
\]

Biểu thức hữu hạn trong `zf_bpsk_theory.m` tương đương:

\[
\mu=\sqrt{\frac{\gamma_s}{1+\gamma_s}},\qquad
a=\frac{1-\mu}{2},\quad b=\frac{1+\mu}{2},
\]

\[
\overline P_{b,ZF}=a^d\sum_{k=0}^{d-1}\binom{d-1+k}{k}b^k.
\]

Trong ba cấu hình đã chọn, `d=1,2,3`. Do vậy độ dốc đường BER ZF cao SNR sẽ khác nhau. Công thức này **không phải lý thuyết BER chung cho MMSE hoặc MF**.

## 4. Quy trình mô phỏng Monte Carlo

1. Thiết lập seed, `Nt`, `NrList`, dải `Es/N0`, giới hạn bit, số fading độc lập và ngưỡng số lỗi.
2. Với từng `Nr` và từng SNR: đổi `Es/N0` sang `N0`.
3. Tạo bit ngẫu nhiên độc lập, chuyển thành ký hiệu BPSK và sắp trên `Nt` luồng.
4. Tạo một ma trận `H` Rayleigh và AWGN phức `Z`; tính `Y=H*X+Z`.
5. Tính `W_ZF`, `W_MMSE`, `W_MRC` từ **cùng `H`**, áp dụng trên **cùng `Y`**.
6. Quyết định bit theo dấu phần thực; đếm sai khác so với bit phát.
7. Lặp cho tới khi đạt đủ số kênh fading và lỗi, hoặc đến giới hạn `maxBits`.
8. Lưu BER, số bit, số lỗi, SINR, thời gian; tính lý thuyết ZF; tạo bảng và đồ thị.

Tất cả số liệu lấy trực tiếp từ chương trình, không gán cứng vào kết quả. Số bit và số lỗi được lưu để đánh giá độ tin cậy. Khi một điểm có quá ít lỗi, báo cáo cần nêu giới hạn và tăng `p.maxBits` nếu cần.

## 5. Độ phức tạp tính toán

Để tính trọng số cho một kênh `H` (không tính khối nhân `W*Y`):

| Detector | Chi phí tính trọng số (bậc lớn) | Nhận xét |
|---|---|---|
| ZF | `O(Nr*Nt^2 + Nt^3)` | Tạo ma trận Gram và giải hệ tuyến tính |
| MMSE | `O(Nr*Nt^2 + Nt^3)` | Thêm ma trận `N0*I` vào Gram trước khi giải hệ |
| MRC/MF | `O(Nr*Nt)` | Tích vô hướng từng cột và chuẩn hóa; không cần nghịch đảo |

Mỗi detector đều cần `O(Nt*Nr*K)` để xử lý một khối nhận `Y` gồm `K` thời điểm ký hiệu. Trong chương trình hiện tại, Gram được tính chung cho cả ba detector để tránh tính lặp.

## 6. Bố cục báo cáo gợi ý (15–25 trang)

**Trang bìa:** trường/khoa, học phần, tên đề tài, thành viên, mã số sinh viên, giảng viên, link video.

**Mục lục và danh mục:** hình, bảng, từ viết tắt.

**Chương 1 – Tổng quan (2–3 trang):** truyền dẫn MIMO; phân biệt spatial multiplexing với spatial diversity; ứng dụng trong LTE/5G/Wi‑Fi. Chỉ trình bày ngắn phần thực sự liên quan đến mô hình.

**Chương 2 – Mô hình và giải thuật (4–6 trang):** sơ đồ khối do nhóm dựng; `Y=HX+Z`; chuẩn hóa, giả thiết CSI, dạng kích thước ma trận; dẫn giải ZF/MMSE/MRC; SINR; BER ZF lý thuyết; độ phức tạp.

**Chương 3 – Hiện thực MATLAB (3–4 trang):** cấu trúc từng file, tham số mô phỏng, thuật toán Monte Carlo, cách tái lập thí nghiệm, cách kiểm chứng lý thuyết và chương trình kiểm tra nội bộ.

**Chương 4 – Kết quả và thảo luận (5–7 trang):** chèn các hình `Fig_Detectors_4x4`, `4x5`, `4x6`; một hoặc nhiều hình so sánh anten; `Fig_ZF_TheoryValidation`; bảng `ber_target_snr_summary.csv`; phân tích BER thấp/cao SNR, gain anten, độ dốc ZF, MRC floor, MMSE gần ZF ở SNR cao. Nêu cả số bit và giới hạn độ chính xác khi cần.

**Chương 5 – Kết luận (1 trang):** những nhận xét có dữ liệu hỗ trợ, giới hạn perfect CSI/Rayleigh/BPSK và hướng mở rộng phù hợp.

**Tài liệu tham khảo:** một chuẩn trích dẫn nhất quán (đề gợi ý IEEE). Có thể bắt đầu với Goldsmith (2005), Tse & Viswanath (2005), Cho et al. (2010), Proakis & Salehi (2008), Marzetta et al. (2016), Larsson et al. (2014) như danh mục trong đề bài. Kiểm tra thông tin sách/trang trước khi trích dẫn chi tiết.

**Phụ lục:** mã nguồn/hướng dẫn sử dụng, phân công nhóm và thông tin tái lập kết quả.

## 7. Câu hỏi nên trả lời bằng các hình số liệu thực tế

- MMSE có lợi thế so với ZF ở vùng SNR nào, vì sao? Giải thích bằng `N0*I` và SINR.
- Khi `Nr` tăng từ 4 lên 5 rồi 6, hình dạng/độ dốc đường ZF thay đổi ra sao?
- MF có sàn lỗi hay không trong dải SNR đã mô phỏng? Không khẳng định sàn lỗi chỉ từ một đoạn đường cong chưa đủ.
- Đường ZF thực nghiệm có gần lý thuyết ở mọi cấu hình không? Nếu không, nêu số lỗi đo được, số fading độc lập và sai số Monte Carlo.
- Để đạt BER mục tiêu `1e-2`, SNR cần thiết là bao nhiêu? Chỉ báo các ô **có giao điểm đo được** trong CSV.
- Thời gian chạy có khác nhau không? Giải thích số phép toán và ảnh hưởng của tiêu chí dừng mô phỏng.

**Lưu ý liêm chính:** Không trình bày các con số mẫu hoặc kết quả chưa chạy như số liệu thực nghiệm. Nếu sử dụng công cụ AI để hỗ trợ, phải ghi rõ công cụ và công việc được hỗ trợ theo yêu cầu của đề bài. Nhóm cần tự hiểu và tự diễn giải mã nguồn/kết quả.
