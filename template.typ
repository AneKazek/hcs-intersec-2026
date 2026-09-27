// ==============================================================================
// FLAT & MINIMALIST CTF WRITEUP TEMPLATE (Typst)
// Struktur dan penulisan terinspirasi dari format standar laporan CTF (contohwu.pdf)
// ==============================================================================

#let ctf-writeup(
  title: "HEROES CYBER SECURITY INTERNAL SELECTION 2026",
  subtitle: none,
  cover-image: "coverphoto.jpg",
  team: "Muhammad Dzaky Haidar",
  authors: (
    "Muhammad Dzaky Haidar (Kazek)",
  ),
  body,
) = {
  // Pengaturan Halaman: Standar margin 1 inci, halaman bersih putih
  set page(
    paper: "a4",
    margin: (x: 2.54cm, top: 2.54cm, bottom: 2.54cm),
    // Footer hanya aktif mulai dari halaman 2
    footer: context {
      let page-num = counter(page).get().first()
      if page-num > 1 {
        align(right)[
          #text(size: 9pt, fill: rgb("#555555"))[
            #team • #counter(page).display("1")
          ]
        ]
      }
    },
  )

  // Tipografi Flat: Arial / Segoe UI, bersih, mudah dibaca
  set text(
    font: ("Arial", "Segoe UI"),
    size: 10.5pt,
    fill: rgb("#111111"),
    lang: "id",
  )

  set par(
    justify: true,
    leading: 0.72em,
  )

  // Styling Heading Bersih & Standar
  show heading: set par(justify: false)

  show heading.where(level: 1): it => block(
    below: 14pt,
    above: 20pt,
    text(size: 16pt, weight: "bold", it.body),
  )

  show heading.where(level: 2): it => block(
    below: 10pt,
    above: 16pt,
    text(size: 13.5pt, weight: "bold", it.body),
  )

  show heading.where(level: 3): it => block(
    below: 8pt,
    above: 12pt,
    text(size: 11pt, weight: "bold", it.body),
  )

  // Styling Table Header Bold
  show table.cell.where(y: 0): set text(weight: "bold")

  // Styling Code Block: Flat light background abu-abu tipis (seperti GitHub / Docs)
  show raw.where(block: true): it => block(
    fill: rgb("#f6f8fa"),
    stroke: 0.5pt + rgb("#d0d7de"),
    inset: (x: 10pt, y: 8pt),
    radius: 4pt,
    width: 100%,
    text(font: ("Consolas", "Courier New"), size: 8.5pt, it),
  )

  show raw.where(block: false): it => box(
    fill: rgb("#f6f8fa"),
    stroke: 0.5pt + rgb("#d0d7de"),
    inset: (x: 3.5pt, y: 1.5pt),
    radius: 3pt,
    baseline: 0%,
    text(font: ("Consolas", "Courier New"), size: 8.5pt, it),
  )

  // Link styling: biru rapi seperti web/docs
  show link: it => text(fill: rgb("#0969da"), underline(it))

  // Styling Gambar: Otomatis rata tengah dengan margin vertikal yang rapi
  show image: it => {
    v(3pt)
    align(center, it)
    v(3pt)
  }

  // Styling Block Math Equation: Spasi vertikal rapi & unbreakable
  show math.equation.where(block: true): it => block(
    above: 8pt,
    below: 8pt,
    breakable: false,
    it,
  )

  // ============================================================================
  // HALAMAN 1: COVER PAGE
  // Rata Tengah (Center Alignment), Judul, Cover Photo di tengah, Presented by di bawah
  // ============================================================================
  {
    set align(center)
    set par(justify: false)

    v(1.2cm)

    // Judul Event CTF Utama (Rata Tengah)
    text(size: 26pt, weight: "bold", upper(title))

    // Subtitle jika ada
    if subtitle != none and subtitle != "" {
      v(10pt)
      text(size: 13pt, fill: rgb("#333333"), subtitle)
    }

    v(1fr)

    // Cover Photo di tengah halaman (Rata Tengah)
    if cover-image != none {
      image(cover-image, width: 62%)
    }

    v(1fr)

    // Info Penulis (Rata Tengah)
    text(size: 11pt, weight: "bold")[Presented by:]
    v(4pt)
    for a in authors [
      #text(size: 11pt, fill: rgb("#111111"))[#a] \
    ]

    v(1.2cm)
  }

  // Pindah ke Halaman 2 (Daftar Isi)
  pagebreak()

  body
}
