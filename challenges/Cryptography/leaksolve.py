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
