# PROJECT PLAN

## Software Gemini Studio

**NO. :** <no.urut dokumen>/PP/Gemini Studio/<bulan_romawi>/<tahun>
**Edisi :** <Bulan Tahun>

### DAFTAR ISI
I. PENDAHULUAN
II. TUJUAN
III. MODUL/FITUR APLIKASI
3.1 Modul Home / Dashboard
3.2 Modul The Writer
3.3 Modul Image Studio
3.4 Modul Director Engine
IV. DESKRIPSI PROSES
4.1 User Flow Proses yang diusulkan
4.2 Penjelasan User Flow Software Gemini Studio
V. RESOURCES
5.1 Sumber Daya Manusia
5.2 Sumber Daya Teknis
VI. TIMELINE

---

### I. PENDAHULUAN
Kemajuan teknologi Kecerdasan Buatan (Artificial Intelligence/AI) seperti Gemini telah mencapai titik di mana mesin tidak lagi hanya mengikuti instruksi kaku, melainkan mampu memahami konteks visual dan tekstual secara mendalam. Kehadiran Gemini API dari Google menandai era baru dalam pengolahan data multimodal, di mana satu model dapat memproses teks, gambar, dan dokumen secara simultan. Idealnya, teknologi secanggih ini seharusnya dapat dimanfaatkan oleh semua lapisan masyarakat, mulai dari pelajar, pelaku UMKM, hingga tenaga profesional untuk meningkatkan produktivitas mereka tanpa perlu memiliki latar belakang teknis yang mendalam.

Namun, kenyataannya menunjukkan terdapat kesenjangan besar antara kecanggihan teknologi dengan kemampuan pengguna dalam mengoperasikannya. Masalah utama yang ditemukan adalah "Prompt Barrier" atau hambatan dalam penyusunan instruksi. Untuk mendapatkan hasil yang akurat dari sebuah AI, pengguna seringkali dituntut untuk menguasai teknik Prompting yang spesifik dan teknis.

Bagi masyarakat awam, menulis instruksi yang mampu mengarahkan AI untuk melakukan pengeditan gambar yang presisi atau analisis dokumen yang mendalam adalah hal yang intimidatif dan memakan waktu. Akibatnya, potensi besar dari teknologi AI seperti Gemini seringkali terbuang percuma hanya karena pengguna tidak tahu kata-kata apa yang harus diketikkan untuk membuat prompt dengan hasil yang akurat.

Platform AI berbasis web saat ini umumnya bersifat umum. Pengguna diberikan kolom teks kosong tanpa panduan yang jelas. Dalam konteks produktivitas, antarmuka seperti ini kurang efisien karena:
- Hasil yang didapat user seringkali tidak konsisten.
- Pengguna harus melakukan banyak langkah (upload, ketik prompt, revisi prompt, download) secara berulang.
- Pengguna harus berpikir keras hanya untuk merumuskan apa yang mereka inginkan ke dalam bahasa yang dipahami mesin.

Berdasarkan permasalahan tersebut, proyek ini mengusulkan pengembangan **Gemini Studio**, sebuah aplikasi multi-platform berbasis wrapper yang bertindak sebagai lapisan penyederhana antara Gemini API dan pengguna akhir. Aplikasi ini tidak lagi menawarkan kolom kosong yang membingungkan, melainkan menghadirkan antarmuka dengan aksi-aksi pintar (Smart Actions) yang telah dioptimasi secara internal. Pengguna cukup mengunggah file atau mengetik draft kasar, lalu memilih aksi seperti "Fix Grammar", "Remove Background", atau "Design Cinematic Script", dan aplikasi secara otomatis menyusun spesifik prompt di balik layar dan mengirimkannya ke server Gemini.

### II. TUJUAN
Berikut merupakan tujuan dari pembuatan software ini:
- Memecahkan "Prompt Barrier" yang dialami oleh masyarakat awam dengan menyediakan Smart Actions siap pakai.
- Menyediakan antarmuka yang intuitif dan dikelompokkan ke dalam studio spesifik (Text, Image, Video) untuk alur kerja yang efisien.
- Memanfaatkan kapabilitas multimodal Gemini API secara optimal pada satu ekosistem aplikasi.

### III. MODUL/FITUR APLIKASI
Berikut dijabarkan modul dan fitur yang terdapat di Software Gemini Studio:

#### 3.1 Modul Home / Dashboard
Modul Home merupakan halaman utama (landing page) yang memberikan akses cepat ke ketiga fitur utama Gemini Studio. Modul ini memiliki fitur yaitu:

| Fitur | Deskripsi |
|---|---|
| Menu Navigasi Studio | Sistem menampilkan pilihan untuk masuk ke The Writer, Image Studio, dan Director Engine. |
| Hero Section | Menampilkan informasi dan penjelasan singkat mengenai aplikasi. |

#### 3.2 Modul The Writer (AI Text Editor)
Modul untuk mengedit dan mengembangkan dokumen teks menggunakan bantuan AI secara real-time. Modul ini memiliki fitur yaitu:

| Fitur | Deskripsi |
|---|---|
| Text Editor & Markdown Preview | Sistem menyediakan editor teks yang mendukung pratinjau format Markdown. |
| Smart Actions | Sistem menyediakan aksi cepat untuk teks yang diblok (Paraphrase, Fix Grammar, Summarize, Tone Shift, Expand, Make it Poetic). |
| Idle Actions | Sistem menyediakan aksi umum saat tidak ada teks yang diblok (Expand Doc, Random Story, Random Letter, Random Poetry). |
| Custom Prompt | Sistem memungkinkan pengguna mengetik instruksi khusus untuk modifikasi teks. |
| Streaming Output | Sistem menampilkan hasil teks generasi AI secara bertahap (real-time). |
| Export to PDF | Sistem menyediakan fungsi untuk menyimpan dan mengunduh editor dalam bentuk file PDF. |

#### 3.3 Modul Image Studio (AI Image Editor)
Modul untuk memanipulasi dan memproses gambar menggunakan model vision dari AI. Modul ini memiliki fitur yaitu:

| Fitur | Deskripsi |
|---|---|
| Upload Image | Sistem memungkinkan pengguna mengunggah gambar ke dalam canvas. |
| Smart Actions | Sistem menyediakan pengeditan otomatis (Remove Background, Black & White, Vibrant, Smart Crop, Sharpen). |
| Artistic Styles | Sistem menyediakan prasetel (template) filter gaya seni artistik pada gambar. |
| Custom Prompt | Sistem memungkinkan pengguna memberi instruksi khusus / custom editan ke gambar. |
| Magic Result Canvas | Sistem menampilkan hasil gambar kembalian dari backend (berbasis base64) ke layar pratinjau. |

#### 3.4 Modul Director Engine (AI Video Storyboarding)
Modul untuk merancang naskah sinematik dan visual storyboard dari sebuah ide kasar. Modul ini memiliki fitur yaitu:

| Fitur | Deskripsi |
|---|---|
| AI Vision Engine | Sistem mengizinkan input ide kasar untuk diubah menjadi Cinematic Script utuh terbaca oleh AI. |
| Visual Timeline / Storyboard | Sistem menyusun adegan (scene) berurutan lengkap dengan perkiraan durasi. |
| Scene Generator | Sistem merancang deskripsi visual naratif dan teks panduan audio untuk tiap adegan. |
| Render Concept | Sistem menggambar ilustrasi konseptual menggunakan grafis SVG untuk adegan yang dipilih. |

### IV. DESKRIPSI PROSES

#### 4.1 User Flow Proses yang diusulkan
*(Merujuk pada dokumen flow chart atau gambar user flow yang ada)*

#### 4.2 Penjelasan User Flow Software Gemini Studio
Pengguna memulai dengan membuka software Gemini Studio. Di halaman utama ini, pengguna disajikan dengan antarmuka yang modern dan dapat memilih salah satu dari tiga fitur utama: The Writer, Image Studio, atau Director Engine.

**The Writer (AI Text Editor)**
Jika pengguna memilih fitur The Writer, mereka akan masuk ke antarmuka editor dokumen berbasis AI. Pengguna dapat mengetik teks secara manual atau menggunakan Custom Prompt untuk menghasilkan sebuah konten otomatis. Tersedia alat bantu Smart Actions secara real-time seperti Paraphrase, Fix Grammar, Summarize, Tone Shift, Expand, serta pilihan generik seperti cerita atau puisi acak (Random Story/Poetry). Permintaan diproses oleh API Gemini di sisi server/backend, lalu teksnya dikembalikan melalui streaming (Real-time). Pengguna kemudian dapat menyimpan teks sebagai dokumen atau mengekspornya langsung ke format PDF melalui opsi di pojok atas.

**Image Studio (AI Image Editor)**
Jika pengguna memilih Image Studio, pengguna diminta untuk mengunggah sebuah karya gambar. Setelah gambar berhasil diunggah, pengguna dapat memilih berbagai aksi pengeditan pintar berbasis Gen AI (Smart Actions), seperti Remove Background, Black & White (B&W), Vibrant, Smart Crop, Sharpen, atau memberikan prompt modifikasi gambar secara khusus (Custom Prompt). Proses ini mengirimkan gambar beserta parameter editan ke server, yang mana AI akan merumuskan dan mengeksekusi script pengeditan menggunakan Python di backend. Hasilnya dikembalikan dalam format base64 dan ditampilkan ke fitur Magic Result Canvas untuk diamati atau diunduh oleh pengguna.

**Director Engine (AI Video Storyboarding)**
Jika pengguna memilih Director Engine, pengguna dapat memasukkan konsep visual atau ide mentah mengenai sebuah ide video sinematik. Perintah ini kemudian dikirim ke backend AI Vision Engine untuk diinterpretasikan menjadi sebuah naskah cerita (Cinematic Script). Setelah naskah selesai, tahapan selanjutnya pengguna bisa menyusun alur waktu rekaman (Visual Timeline / Storyboard) secara terurut dari adegan ke adegan (Scene). Setiap adegan kemudian bisa di-render secara konseptual (Render Concept), yang mana AI merancang visual asset adegannya dengan grafis SVG (Scalable Vector Graphics) beserta deskripsi dan instruksi audio vokal. 

Setelah setiap rangkaian intervensi tugas (creative action) dari salah satu fitur tersebut selesai, pengguna memiliki opsi untuk menyimpan dan mendistribusikan hasil pekerjaannya masing-masing.

### V. RESOURCES

#### 5.1 Sumber Daya Manusia
*(Diisi sesuai kebutuhan komposisi tim pengerjaan software)*

#### 5.2 Sumber Daya Teknis
Pengembangan Software ini membutuhkan sumber daya perangkat keras dan perangkat lunak dengan spesifikasi sebagai berikut:

| No | Requirements | Teknologi |
|---|---|---|
| **Hardware** | | |
| 1 | Laptop/PC | Perangkat kerja dengan spesifikasi minimum:<br>CPU: Intel Core i5 – i7 \| RAM: 8GB – 16GB \| Storage: 256GB – 2TB SSD |
| **Software** | | |
| 1 | Database | SQLite |
| 2 | Backend | Python (Django) & Gemini API |
| 3 | Frontend | Flutter |
| 4 | Version control | Git |
| 5 | Dev tools | Visual Studio Code / Zed Editor |

### VI. TIMELINE
*(Diisi sesuai rencana waktu proses pengembangan software)*
