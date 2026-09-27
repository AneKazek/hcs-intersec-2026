#import "template.typ": *

#show: ctf-writeup.with(
  title: "HEROES CYBER SECURITY INTERNAL SELECTION 2026",
  cover-image: "coverphoto.jpg",
  authors: (
    "Muhammad Dzaky Haidar (Kazek)",
  ),
  team: "Muhammad Dzaky Haidar (Kazek)",
)

// ==============================================================================
// HALAMAN 2: DAFTAR ISI
// ==============================================================================
#outline(
  title: "DAFTAR ISI",
  indent: 1.5em,
  depth: 2,
)

#pagebreak()

// ==============================================================================
// [ REVERSE ENGINEERING ]
// ==============================================================================
= [ REVERSE ENGINEERING ]

== JasJus

*Flag* \
`HCS{$el@M4t_nA8IL_afri2@l_AD41AH_s0$OK_4511_PRes1D3N_84yAN6AN_hcS}`

*Deskripsi* \
Author: Revvv \
Points: 229 pts | Difficulty: easy \
Simpel ini yakali gabisa le \
Files: `chall.js`

*Solusi* \
Pada soal ini di dapatkan sebuah file bernama `chall.js` yang dimana kalau dilihat-lihat file ini akan membandingkan input dari user dengan array yang terenkripsi `_d`.

Setelah mengekstrak file `chall.js`, langkah awal yang saya lakukan adalah membaca struktur programnya secara keseluruhan. Script ini berbasis Node.js yang menerima input flag dari terminal melalui interface `readline`. Program akan mengubah setiap karakter string input menjadi nilai kode ASCII (byte) lalu memprosesnya melalui fungsi enkripsi custom sebelum mencocokkannya dengan data ciphertext yang sudah tertanam di file.

bisa dilihat pada code snippet berikut fungsi pembandingnya:

#image("figures/jasjus/part2-chall.js.png", width: 65%)

Dari potongan kode fungsi pembanding di atas, terlihat jelas bahwa sebelum dilakukan komparasi elemen array, program terlebih dahulu melakukan validasi panjang input: `if (flag.length !== _d.length) return false;`. Dari sini kita langsung mendapatkan informasi penting mengenai panjang flag yang dicari, yakni harus tepat sama dengan jumlah elemen pada array `_d` yaitu sebanyak 65 karakter.

yang dimana kalau kita coba jalankan file JS nya akan di mintai flag sebagai berikut:

#image("figures/jasjus/part3-chall.js.png", width: 60%)


karena hal tersebut saya cek kembali source codenya, dan ditemukan bahwa di dalam source codenya sendiri mengandung rumus dalam enkripsi dari array `_d` yakni:

#text(size: 16pt, weight: "bold")[ $ c = (c + i times 3 + 7) space mod space 256 $ ]

Jika kita bedah fungsi enkripsinya pada `part1-chall.js.png`, alur matematis yang diterapkan pada setiap karakter input adalah sebagai berikut:
1. Karakter input pada indeks ke-$i$ di-XOR terlebih dahulu dengan array key berulang `k = [13, 37, 42]`, yaitu `c = c ^ k[i % 3]`.
2. Hasil XOR tersebut kemudian ditambahkan dengan nilai offset linear berbasis indeks: `(i * 3 + 7)`.
3. Hasil penjumlahan di-modulo 256 (`& 0xFF`) agar nilainya tetap berada dalam rentang 1 byte (0–255).
4. Yang tidak kalah penting, di akhir proses enkripsi, seluruh array hasil ternyata dibalik urutannya (*reverse*) sebelum disimpan ke dalam array `_d`.

sampai disini saya langsung menghubungi sahabat baik saya SENOPATI untuk saya pecut dalam pengerjaan soal kali ini, yang dimana disini saya dapatkan sebuah solver yang saya jalankan dan ternyata berhasil mendapatkan flag tersebut. berikut solvernya:

Logika solver ini bekerja dengan cara membalikkan (*revert*) seluruh tahapan enkripsi dari belakang ke depan:
1. Membalikkan kembali urutan array `_d` ke urutan aslinya menggunakan slicing Python `d[::-1]`.
2. Membatalkan penambahan offset dinamis dengan mengurangkan `(i * 3 + 7)` lalu di-bitwise AND dengan `0xFF` agar nilainya tetap positif.
3. Membatalkan operasi XOR dengan melakukan XOR ulang menggunakan key array `k[i % len(k)]` (karena sifat operasi XOR adalah involutif, yaitu $A xor B xor B = A$).
4. Mengubah byte integer kembali menjadi karakter string menggunakan `chr(c)`.

#pagebreak()

Script solver (`solverevy.py`):
```python
k = [13, 37, 42]
d = [
    33, 61, 50, 3, 56, 254, 35, 200, 245, 26, 8,
    226, 184, 29, 227, 182, 251, 211, 237, 209,
    237, 5, 2, 193, 157, 143, 181, 238, 228, 181,
    126, 130, 232, 220, 209, 173, 121, 108, 161,
    192, 204, 176, 182, 96, 170, 155, 131, 169,
    175, 160, 120, 67, 146, 142, 157, 118, 91,
    134, 129, 122, 101, 20, 134, 134, 112, 76
]

enc = d[::-1]          # reverse
flag = ""

for i, val in enumerate(enc):
    temp = (val - (i * 3 + 7)) & 0xFF   # undo "+ i*3+7"
    c = temp ^ k[i % len(k)]           # undo xor dengan key
    flag += chr(c)

print(flag)
```

#image("figures/jasjus/part4-chall.js.png", width: 75%)

*AI History:* \
https://chat.ragita.net/s/b72dd9e1-3642-4457-81de-940e6a1527e2

#pagebreak()

== artsci

*Flag* \
`HCS{3z_3s0l4ng_r3v}`

*Deskripsi* \
Author: kek.c \
Points: 481 pts | Tags: esolang, agak sedeng, spurane \
Rev agak sedeng \
https://ajanse.me/asciidots/ \
Files: `chall.txt` (6.4 KB)

*Solusi* \
Challenge ini tu diminta nge trace bola bola dari asciidots ini, yang dimana bola ini akan bergerak sesuai dengan operator yang dilewatinya, sebelum itu berikut sedikit penjelasan tentang operatornya yang dimana DIAMBIL LANGSUNG DARI WEBSITENYTA:

AsciiDots sendiri adalah bahasa pemrograman esoterik (esolang) berbasis visual 2D ASCII art, di mana aliran logika dieksekusi oleh titik (*dot*) yang menggelinding di sepanjang lintasan kawat karakter seperti `-`, `|`, `/`, dan `\`. Setiap kali dot melewati operator matematika atau logika, nilainya akan berubah sesuai aturan operator tersebut.

=== Operations
- `[*]` multiplies the value that passes through vertically by the value that runs into it horizontally. When a dot arrives here, it waits for another dot to arrive from a perpendicular direction. When that dot arrives, the dot that arrived from the top or bottom has its value updated and it continues through the opposite side. The dot that passed through horizontally is deleted.
- `{ architecture / * }` does the same except it multiplies the value that enters horizontally by the value that enters vertically. The resulting dot exits horizontally.

Other operations work similarly:

#table(
  columns: (auto, 1fr, auto, 1fr),
  stroke: 0.5pt + rgb("#d0d7de"),
  inset: (x: 7pt, y: 2.5pt),
  fill: (col, row) => if row == 0 { rgb("#f6f8fa") } else { none },
  align: (center + horizon, left + horizon, center + horizon, left + horizon),
  [*Operator*], [*Fungsi*], [*Operator*], [*Fungsi*],
  [`+`], [add], [`=`], [equal],
  [`-`], [subtract], [`!`], [not equal],
  [`*`], [multiply], [`>`], [greater],
  [`/`], [divide], [`<`], [less],
  [`%`], [modulo], [`G`], [greater or equal],
  [`^`], [exponent], [`L`], [less or equal],
  [`&`], [bitwise AND], [`o`], [bitwise OR],
  [`x`], [bitwise XOR], [], [],
)

These characters are only considered operators when located within brackets. Outside of brackets, symbols like `+` perform their regular functions.

#block(breakable: false)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 14pt,
    [
      *Example of subtraction ($3 - 2 = 1$):*
      ```text
        #
        $
        |
      [-]-2#-.
        |
        3
        #
        |
        .
      ```
    ],
    [
      *Calculating sum of two input values:*
      ```text
      .-#?-{+}-$#
           |
      .-#?--/
      ```
    ]
  )
]


Nah setelah memahami bagaimana constructornya,pertama-tama kita coba masukkin semua codenya ke decodernya.

#image("figures/artsci/part1.png", width: 53%)

File `chall.txt` ini ternyata berisi satu diagram sirkuit ASCII raksasa bertuliskan logo "HCS". Seluruh karakter flag kita diuji di dalam labirin sirkuit ini dengan titik-titik dot yang bergerak melintasi operator matematika dan bitwise secara sistematis.

yang ternyata kalau di teliti lagi ini ascii nya gerak mengikuti jalannya dan dimulai dari tanda `.` . Setelah mengetahui hal tersebut saya langsung coba tracing yang pertama, yang tentunya di bantu oleh mas faiz selama optick awkoakwkaw. Yang pertama sendiri adalah angka 18 yang mana di dapatkan dari operator `[=]` disini saya sempet ngiranya operator `[=]` itu selang seling dengan `{=}` ternyata saya salah.

#image("figures/artsci/part2.png", width: 22%)

nah di 18 ini dia itu karena tanda `.` ada di sebelah kiri daripada 18 artinya ini bergerak dari kiri angka 18 ke arah kanan 18 mengikuti jalan nya.  kemudian disini ternyata dia nabrak dengan operator `{x}`  dan kebetulan di atasnya juga ada angka 90.

Karena dot meluncur dari kiri angka 18 dan bertabrakan dengan operator XOR `{x}` yang memiliki input vertikal bernilai 90, maka secara matematis dot tersebut mengalami operasi $18 xor 90$.

dari sini saya kepikiran langsung coba bertanya ke ai saya, dan ternyata hasilnya cukup bikin saya penasaran karena kalau di konversi ke teks asli 72 itu menghasilkan huruf `H` yang sepengetahuan saya itu adalah huruf paling depan dari flag formatnya.

#image("figures/artsci/part3.png", width: 73%)


kemudian disini saya lanjut menelusuri angka selanjutnya yaitu angka 61

#image("figures/artsci/part4.png", width: 32%)

namun disini ada yang menarik, tanda `.` nya ada di samping kanan angka 61 yang berarti dia bergerak dari kanan ke kiri yang jika di trace, dia terbaca sebagai angka `16` dan masih bakal nabrak tanda `{x}` dan akan terjadi ` XOR`. Namun setelah di XOR dia akan muncul lagi dari atas yakni yang titik di atas 7.

Karena dot bergerak dari kanan ke kiri melintasi angka 61, digit yang pertama kali dilewati adalah angka 1 lalu angka 6, sehingga nilai yang dibawa dot adalah 16. Nilai ini kemudian di-XOR dengan 90 menghasilkan $16 xor 90 = 74$.

disini tadi saya berhipotesis singkat kalau input pasti akan di xor, disini saya tanya lagi ke ai saya,

#image("figures/artsci/part5.png", width: 68%)

tapi disini yang perlu di note adalah ini itu hasil akhirnya, sehingga kan tadi ada operasi `{+}` sehingga harus di pindah ruaskan dulu, jadi di kurangi 7, alhasil mendapatkan 67 yang mana ini kalau jadi teks asli menjadi C, semakin mendekati flag format nih.

lanjut ke karakter berikutnya, yakni 59.

#image("figures/artsci/part6.png", width: 37%)

disini titik dimulai dari atas ke bawah, nah kenapa saya yakin yang 59 bukan yang 14 karena tanda `{=}`  bertepatan di bawah angka 59, ini sesuai dengan pola pada angka2 sebelumnya. Nah disini saya menemukan bahwa kalo di tracing lagi mirip nih sama yang sebelumnya bedanya dia di kurangi 14, yang mana saya lempar ai lagi tapi karena udah gak sabaran saya nekat menyimpulkan pengurangannya ini kelipatan 7. sehingga di dapatkan rumus:

#align(center)[
  #v(14pt)
  #text(size: 16pt, weight: "bold")[
    $ "char"_i = ("val"_i xor 90) - (i times 7) $
  ]
  #v(14pt)
]



Dimana:
- $"val"_i$ adalah angka yang didapatkan dari hasil tracing lintasan titik (dot).
- $i$ adalah indeks urutan karakter (dimulai dari $i = 0, 1, 2, dots$).
- $i times 7$ adalah faktor pengurangan bertahap dengan kelipatan 7.

Sebagai contoh verifikasi 3 karakter pertama:
- $i = 0 arrow (18 xor 90) - 0 = 72 arrow$ `'H'`
- $i = 1 arrow (16 xor 90) - 7 = 74 - 7 = 67 arrow$ `'C'`
- $i = 2 arrow (59 xor 90) - 14 = 97 - 14 = 83 arrow$ `'S'`


#pagebreak()

Pola barisan pengurangan bertahap ($0, 7, 14, 21, dots$) ini membentuk barisan aritmetika murni dengan beda $b = 7$. Dengan ditemukannya pola keteraturan matematis ini, kita tidak perlu lagi menghabiskan waktu berjam-jam untuk men-trace setiap percabangan kawat yang rumit di dalam file `chall.txt`.

nah disini karena udah bakal nguli banyak, sebenernya saya tinggal nyari angka titik mulai nya lalu saya lempar ai. titik mulainya itu ada `18, 16, 59, 202, 21, 199, 211, 62, 241, 53, 232, 219, 152, 152, 155, 129, 249, 183, 161`

Berikut hasil pemetaan lengkap dari 19 titik awal yang diolah menggunakan rumus di atas:

#table(
  columns: (auto, auto, auto, auto, auto, 1fr),
  stroke: 0.5pt + rgb("#d0d7de"),
  inset: (x: 5pt, y: 2pt),
  fill: (col, row) => if row == 0 { rgb("#f6f8fa") } else { none },
  align: (center, center, center, center, center, center),
  [*$i$*], [*Val*], [*Val $xor 90$*], [*$- (i times 7)$*], [*ASCII*], [*Karakter*],
  [0], [18], [72], [-0], [72], [`H`],
  [1], [16], [74], [-7], [67], [`C`],
  [2], [59], [97], [-14], [83], [`S`],
  [3], [202], [144], [-21], [123], [`{`],
  [4], [21], [79], [-28], [51], [`3`],
  [5], [199], [157], [-35], [122], [`z`],
  [6], [211], [137], [-42], [95], [`_`],
  [7], [62], [100], [-49], [51], [`3`],
  [8], [241], [171], [-56], [115], [`s`],
  [9], [53], [111], [-63], [48], [`0`],
  [10], [232], [178], [-70], [108], [`l`],
  [11], [219], [131], [-77], [54], [`4`],
  [12], [152], [242], [-84], [110], [`n`],
  [13], [152], [242], [-91], [103], [`g`],
  [14], [155], [241], [-98], [95], [`_`],
  [15], [129], [219], [-105], [114], [`r`],
  [16], [249], [163], [-112], [51], [`3`],
  [17], [183], [237], [-119], [118], [`v`],
  [18], [161], [251], [-126], [125], [`}`],
)

dan yap, lempar ai suruh pake rumus nya and convert to text.

#image("figures/artsci/part7.png", width: 90%)

*AI History:* \
https://chat.ragita.net/s/58453bab-411d-45de-ba55-78695117be7e

#pagebreak()

// ==============================================================================
// [ CRYPTOGRAPHY ]
// ==============================================================================
= [ CRYPTOGRAPHY ]

== LE4K

*Flag* \
`HCS{L3AK_fr0m_t3mu__771db76a78}`

*Deskripsi* \
Author: RAVEN \
Points: 436 pts | Difficulty: easy \
Leaks again...

*Solusi* \
Pada challenge ini kita diberikan sebuah file python bernama `chall.py`. Kalau kita baca kodenya, intinya server menjalankan service RSA interaktif sebanyak 5 ronde, dimana tiap ronde server membocorkan nilai $n$, $e$, $c$, dan nilai unik bernama $h m m m$.

Pada kriptografi RSA yang aman, kekuatan enkripsi bersandar pada sulitnya memfaktorkan modulus $n = p times q$ yang terdiri dari perkalian dua bilangan prima acak berukuran besar yang independen. Namun dalam challenge ini, terdapat kelemahan fatal pada prosedur pembuatan bilangan prima $q$.

#image("figures/le4k/part1.png", width: 77%)

Disini terdapat bagian yang mencurigakan itu di bagian pembuatan nilai $q$ pada fungsi `generate_instance()`:

```python
hmmm = random.randint(67, 6767)
q = inverse(hmmm, p) + p
```

Setelah di perhatikan, nilai $h m m m$ cuma angka random  yang berada di antara 67 hingga 6767. Berdasarkan definisi modular inverse:

$ "inverse"(h m m m, p) times h m m m equiv 1 space (mod space p) $

Artinya terdapat suatu integer $k$ sedemikian rupa sehingga:

$ "inverse"(h m m m, p) times h m m m = k times p + 1 $

Karena $q = "inverse"(h m m m, p) + p$, kalau kedua ruas dikalikan $h m m m$:

$ q times h m m m = (k times p + 1) + (p times h m m m) = p times (k + h m m m) + 1 $

Lalu kalau dikalikan lagi dengan $p$ (ingat $n = p times q$):

$ n times h m m m approx p^2 times (h m m m + k) $
$ p approx floor(sqrt((h m m m times n) / (h m m m + k))) $


Mengapa nilai $k$ dijamin bernilai sangat kecil? Berdasarkan sifat modular inverse, $"inverse"(h m m m, p)$ selalu bernilai lebih kecil dari $p$ ($0 < "inv" < p$). Saat dikalikan dengan $h m m m$, nilainya pasti lebih kecil dari $h m m m times p$. Akibatnya, saat dibagi dengan $p$, nilai hasil bagi bulat $k = floor(("inv" times h m m m) / p)$ dijamin berada di bawah $h m m m$. Karena nilai batas atas $h m m m$ hanya 6767, rentang pencarian nilai $k$ hanya dari $1$ sampai maksimal $6767$.

Karena nilai $k$ itu sangat kecil yang dimana rentangnya hanya dari $1$ sampai $h m m m$, disini kita bisa langsung brute-force nilai $k$ yang cuma ribuan ini, yang dimana tinggal dicek apakah $n space mod space p == 0$. kalo habis dibagi, berarti otomatis $p$ dan $q$ ketemu.

Setelah faktor prima $p$ dan $q$ berhasil ditemukan:
1. Kita menghitung fungsi Euler Totient: $phi(n) = (p - 1)(q - 1)$.
2. Menghitung private key RSA: $d = e^(-1) mod phi(n)$ dengan $e = 65537$.
3. Mendekripsi ciphertext $c$ untuk memperoleh token rahasia: $m = c^d mod n$.
4. Mengubah integer token menjadi 16-byte big-endian hex string dan mengirimkannya kembali ke server.

langsung aja disini saya pecut ai saya untuk bikin solver.

Berikut solver lengkapnya (`leaksolve.py`):

```python
#!/usr/bin/env python3
# -------------------------------------------------------------
#  Solver untuk challleak‑style challenge
#
#  - Baca data hingga "(hex): " setiap ronde
#  - Faktorisasi menggunakan rumus akar:
#        for k in 1..hmmm:  p = floor( sqrt((h*n)/(h+k)) )
#        jika n % p == 0 → q = n // p
#  - Token dikembalikan sebagai 16‑byte big‑endian
# -------------------------------------------------------------

import socket, ssl, re, math
from Crypto.Util.number import inverse

HOST   = "le4k-273eca286437.challenge.hcs-team.com"
PORT   = 1337
ROUNDS = 5          # sesuai script generate_instance() [1]

def recv_until(target: str) -> str:
    """Baca data sampai substring *target* muncul."""
    buf = b""
    while target.encode() not in buf:
        chunk = ssl_sock.recv(4096)
        if not chunk:                     # koneksi ditutup
            break
        buf += chunk
    return buf.decode()

def factor_by_root(n: int, h: int):
    """Kembalikan (p,q) memakai rumus akar."""
    for k in range(1, h + 1):
        p = math.isqrt((h * n) // (h + k))
        if p == 0:
            continue
        if n % p == 0:                      # faktor ditemukan
            return p, n // p
    raise ValueError("Tidak dapat memfaktorkan n dengan metode ini")

# ------------------- koneksi TLS -------------------
sock     = socket.create_connection((HOST, PORT))
ctx      = ssl.create_default_context()
ssl_sock = ctx.wrap_socket(sock, server_hostname=HOST)

for round_id in range(1, ROUNDS + 1):
    # baca header "Round X"

    # ambil blok data hingga "(hex): "
    data = recv_until("(hex): ")

    # parse n, e, c, hmmm
    n   = int(re.search(r"n=(\d+)", data).group(1))
    e   = int(re.search(r"e=(\d+)", data).group(1))      # 65537
    c   = int(re.search(r"c=(\d+)", data).group(1))
    hmmm= int(re.search(r"hmmm=(\d+)", data).group(1))

    print(f"\n-> n={n}\ne={e}\nc={c}\nhmmm={hmmm}")

    # faktorisasi dan dekripsi
    p, q = factor_by_root(n, hmmm)
    phi   = (p - 1) * (q - 1)
    d     = inverse(e, phi)

    m            = pow(c, d, n)             # hasil dekripsi sebagai integer
    token_bytes  = m.to_bytes(16, 'big')      # 16‑byte big‑endian

    # kirim token kembali ke server
    ssl_sock.sendall((token_bytes.hex() + "\n").encode())

    # baca respons (mis. "Wrong." atau flag)

print("\n=== FLAG ===")
print(ssl_sock.recv(4096).decode().strip())
```


setelah ini berjalan, dan selesai 5 ronde dapet deh flagnya.

#image("figures/le4k/part3.png", width: 98%)

*AI History:* \
https://chat.ragita.net/s/e0c7e589-8139-4822-9c41-4a6730dd36a8

#pagebreak()

// ==============================================================================
// [ WEB EXPLOITATION ]
// ==============================================================================
= [ WEB EXPLOITATION ]

== Ape

*Flag* \
`HCS{gH4r0WWwwWWWWWWWwWWwwWWWww_K1ng_g17HuB_6U3_4ku1n_}`

*Deskripsi* \
Author: xeloooo \
Points: 281 pts | Difficulty: easy \
ini web ape sih?? kaga jelas bat dah. udah Gitu isinya ape ape doang. kaga niat sumpah ni dev nya maen deploy aje, kaga di bersihin dulu

*Solusi* \
saat saya coba masuk ke website nya ternyata gaada isinya, di klik apapun ndak ada responsenya...

Ketika pertama kali mengakses website tantangan, saya langsung melakukan inspeksi elemen melalui DevTools browser (F12) serta memeriksa view-source (Ctrl+U) dan tab Network. Hasilnya cuma ada elemen front-end visual statis dengan tombol-tombol yang tidak mengirimkan HTTP request atau form submission apa pun ke backend.

#image("figures/ape/part1.png", width: 66%)

Karena gaada isinya, saya coba cek file `robots.txt` di URL-nya (`/robots.txt`).

Di dunia web development, file `robots.txt` digunakan untuk memandu web crawler search engine agar tidak mengindeks direktori tertentu. Namun dalam konteks keamanan siber, file ini justru sering menjadi sumber *Information Disclosure* karena mengungkap lokasi endpoint tersembunyi yang ingin disembunyikan developer.

#image("figures/ape/part2.png", width: 35%)

Ternyata isi dari `robots.txt` mencantumkan aturan `Disallow: /.git/`. Ini menandakan bahwa folder repository Git di-hosting langsung di dalam direktori publik web server.


Sesuai dengan deskripsi soalnya yang bilang dev-nya kaga bersihin dulu pas deploy, berarti folder git-nya masih nempel di server. Langsung aja disini saya hajar dump seluruh repository `.git` nya menggunakan `git-dumper`.

Tool `git-dumper` akan bekerja dengan mengirimkan HTTP request secara rekursif untuk mengambil file metadata Git, mulai dari commit objects, index, referensi branch, hingga packfiles, lalu menyusun ulang repositori Git tersebut secara utuh di mesin lokal kita.

```bash
git-dumper https://ape-2579baadd3bc.challenge.hcs-team.com web/out/
```

#image("figures/ape/part3.png", width: 40%)

Setelah selesai di-dump, saya langsung masuk ke direktori output foldernya (`out/`) lalu coba intip histori perubahannya menggunakan command `git log -p`.

Fitur riwayat Git menyimpan setiap rekaman commit lengkap beserta perbedaan (*diff*) perubahannya. Seringkali developer yang menyadari ada file rahasia yang tidak sengaja ter-commit akan membuat commit baru untuk menghapusnya (misalnya commit berjudul *"clean up before going live"*). Namun, riwayat Git tidak pernah menghapus catatan masa lalu kecuali di-*purge* secara khusus. Opsi `-p` pada `git log` menampilkan patch baris per baris secara gamblang.

#image("figures/ape/part4.png", width: 36%)

Dan ternyata flag langsung di dapatkan.

Pada diff commit tersebut, terlihat baris yang dihapus (`-`) pada file `README_INTERNAL.md` yang memuat flag kompetisi dalam format teks terbuka (*plaintext*).

*AI History:* \
https://chat.ragita.net/s/4889e045-d826-4e8d-83f4-abd02e0f125a

#pagebreak()

// ==============================================================================
// [ BINARY EXPLOITATION ]
// ==============================================================================
= [ BINARY EXPLOITATION ]

== welcome-to-hcs

*Flag* \
`HCS{g0ddamnNN_YoU_M4de_17_P4ls_533_Y0u_1n_HCS_^^_}`

*Deskripsi* \
Author: TSakuyaiba \
Points: 281 pts | Difficulty: easy \
Just a little welcome for new welcomers ^^ \
Files: `chall` (16 KB)

*Solusi* \
Diberikan sebuah file binary. Disini langsung saja saya execute sebuah command untuk checking proteksi dari binary nya dengan `checksec`.

#image("figures/welcometohcs/part1.png", width: 51%)

disini, setelah di coba command kita dapati bahwa:
- *No Canary*: Kita bebas menimpa stack tanpa takut kena deteksi stack smashing. Pada binary yang aman, compiler biasanya menyisipkan nilai acak (canary) sebelum alamat return. Jika nilai canary berubah saat fungsi selesai dieksekusi, program akan langsung berhenti dengan pesan error `stack smashing detected`. Tanpa canary, penimpaan memori stack dapat dilakukan secara leluasa.
- *No PIE*: Alamat fungsi-fungsinya statis di memori. Seluruh segmen kode program selalu dimuat pada alamat memori virtual tetap di sekitar `0x400000`, sehingga kita tidak memerlukan memory leak untuk mem-bypass ASLR (Address Space Layout Randomization).
- *NX Enabled*: Daerah stack ditandai sebagai non-executable, sehingga kita tidak bisa menjalankan shellcode langsung di stack. Karena itu, teknik eksploitasi yang paling cocok adalah *Code Reuse* atau *ret2win*.

setelah itu, langsung saya coba buka di IDA milik saya, yang dimana fungsi `main`, program ternyata langsung memanggil fungsi `vuln()`:

#image("figures/welcometohcs/part4.png", width: 58%)

setelah masuk ke fungsi `vuln()`, ternyata soalnya  mirip kek  soal *ret2win*

#image("figures/welcometohcs/part6.png", width: 65%)


Di dalam fungsi `vuln()`, variabel buffer dialokasikan hanya 32 bytes (`char v1[32]`), namun fungsi input yang digunakan adalah `gets(v1)` yang sama sekali tidak membatasi panjang input pengguna. Ini jelas merupakan celah *Buffer Overflow*.

Fungsi pustaka `gets()` dalam bahasa C terkenal sangat berbahaya dan telah dihapus dari standar modern karena tidak menerima parameter batasan ukuran input buffer. Berapa pun panjang teks yang dimasukkan user melalui stdin akan terus disalin ke dalam stack frame memori, menimpa variabel lokal lain dan struktur penting di atasnya.

Kemudian saat saya telusuri fungsi-fungsi lainnya di IDA, ditemukan sebuah fungsi bernama `win()` yang berada di alamat `0x40127b`:

#image("figures/welcometohcs/part7.png", width: 55%)

Fungsi `win()` ini langsung membuka dan membaca file `flag.txt`! Jadi objektif kita tinggal menimpa return address (*Saved RIP*) di stack agar langsung melompat ke alamat fungsi `win()`.

Struktur memori stack frame 64-bit pada saat fungsi `vuln()` berjalan tersusun sebagai berikut:
1. Buffer lokal `v1` berukuran 32 bytes (`[rsp+0h] [rbp-20h]`).
2. Saved Base Pointer (`Saved RBP`) milik fungsi pemanggil berukuran 8 bytes.
3. Return Address (`Saved RIP`) yang menentukan instruksi berikutnya setelah fungsi `vuln()` selesai.

Berikut perhitungan matematis untuk menentukan panjang padding buffer overflow-nya:

$ "Offset Padding" = "Ukuran Buffer" + "Ukuran Saved RBP" $
$ "Offset Padding" = 32 " bytes" + 8 " bytes" = 40 " bytes" $

$ "Payload" = ("40 bytes dummy") + "Alamat Fungsi win (0x40127b)" $

#pagebreak()

Setelah rumus offset-nya ketemu, langsung saja saya minta senopati cari solver ret2win terus modif buffernya:

```python
#!/usr/bin/env python3
from pwn import *

host = 'welcome-to-hcs-bfd0f094e6ed.challenge.hcs-team.com'
port = 1337

# 1. Buat koneksi remote dengan TLS/SSL
r = remote(host, port, ssl=True)

# 2. Bangun payload ret2win: 40 bytes padding + alamat fungsi win
payload = b'A' * 40 + p64(0x40127b)

# 3. Kirim payload dan masuk ke mode interaktif
r.sendline(payload)
r.interactive()
```

setelah payload dikirim ke server, eksekusi program langsung dibelokkan ke fungsi `win()` dan flag berhasil kita dapatkan!

#image("figures/welcometohcs/part8.png", width: 62%)

*AI History:* \
https://chat.ragita.net/s/ec8e2794-f042-4af2-a3bc-1ca1d952692a
