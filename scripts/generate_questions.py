import json
import random
import os

levels = []
id_counter = 1

# --- TIER 1 (Level 1-10) ---
t1_senders = ["admin@paypal-update.com", "support@bca-verify.net", "security@facebook-login.org", "info@netflix-billing.com", "alert@google-security.net", "admin@tokopedia-promo.com", "cs@shopee-pay.net", "no-reply@instagram-badge.com", "verify@whatsapp-web.net", "support@apple-icloud.org"]
t1_requests = ["password lamamu", "nomor kartu kredit", "kode OTP", "PIN ATM", "foto KTP", "nama ibu kandung", "CVV kartu", "kode verifikasi email", "password email", "tanggal lahir"]
t1_platforms = ["Facebook", "Instagram", "WhatsApp", "Google", "Twitter", "LinkedIn", "TikTok", "Shopee", "Gojek", "Netflix"]
t1_socials = ["Facebook", "Instagram", "Twitter", "LinkedIn", "TikTok", "Discord", "Snapchat", "Telegram", "Reddit", "Pinterest"]
t1_targets = ["bank", "media sosial", "email", "e-commerce", "game online", "dompet digital", "aplikasi chat", "situs pemerintah", "forum", "situs streaming"]

# --- TIER 2 (Level 11-20) ---
t2_locations = ["kafe", "bandara", "stasiun", "hotel", "taman kota", "perpustakaan", "kampus", "mall", "rumah sakit", "restoran"]
t2_malware_actions = [
    ("menyandera file dan meminta tebusan", "Ransomware"),
    ("menyembunyikan diri dalam program yang tampak sah", "Trojan"),
    ("menggandakan diri melalui jaringan tanpa interaksi user", "Worm"),
    ("merekam ketikan keyboard", "Keylogger"),
    ("menampilkan iklan yang mengganggu terus-menerus", "Adware"),
    ("memberikan akses kontrol penuh dari jarak jauh", "RAT (Remote Access Trojan)"),
    ("menggunakan komputer korban untuk menambang kripto", "Cryptominer"),
    ("mengubah pengaturan DNS secara diam-diam", "DNS Hijacker"),
    ("merusak sektor boot hard drive", "Boot Sector Virus"),
    ("mencuri cookie sesi dari browser", "Spyware")
]
t2_social_methods = [
    ("menelpon sebagai IT support palsu", "Vishing (Voice Phishing)"),
    ("mengirim SMS berisi link undian palsu", "Smishing"),
    ("berpura-pura menjadi CEO perusahaan via email", "Whaling"),
    ("meninggalkan flashdisk berisi malware di tempat parkir", "Baiting"),
    ("mengikuti karyawan masuk ke ruang server tanpa kartu akses", "Tailgating"),
    ("membuat profil LinkedIn palsu untuk merekrut karyawan", "Pretexting"),
    ("mengubah URL agar mirip dengan aslinya", "Typosquatting"),
    ("mengaduk-aduk tempat sampah untuk mencari dokumen rahasia", "Dumpster Diving"),
    ("melihat ketikan password dari belakang bahu", "Shoulder Surfing"),
    ("menawarkan bantuan teknis yang tidak diminta", "Quid Pro Quo")
]

# --- TIER 3 (Level 21-30) ---
t3_protocols = [("HTTP", "80"), ("HTTPS", "443"), ("SSH", "22"), ("FTP", "21"), ("DNS", "53"), ("SMTP", "25"), ("RDP", "3389"), ("Telnet", "23"), ("SMB", "445"), ("POP3", "110")]
t3_cia = [
    ("Confidentiality (Kerahasiaan)", "mencegah data diakses oleh pihak tak berwenang"),
    ("Integrity (Integritas)", "mencegah data diubah oleh pihak tak berwenang"),
    ("Availability (Ketersediaan)", "memastikan layanan selalu bisa diakses saat dibutuhkan")
]
t3_algorithms = [
    ("AES", "Simetris"), ("RSA", "Asimetris"), ("DES", "Simetris"), ("ECC", "Asimetris"), ("Blowfish", "Simetris"),
    ("RC4", "Simetris"), ("Diffie-Hellman", "Asimetris (Key Exchange)"), ("Twofish", "Simetris"), ("DSA", "Asimetris"), ("ChaCha20", "Simetris")
]
t3_firewalls = [
    ("Packet Filtering", "menyaring trafik berdasarkan IP dan Port"),
    ("Stateful Inspection", "melacak status koneksi aktif"),
    ("WAF (Web Application Firewall)", "melindungi web dari serangan layer 7 seperti SQLi"),
    ("NGFW (Next-Gen Firewall)", "menggabungkan DPI, IPS, dan kontrol aplikasi"),
    ("Proxy Firewall", "bertindak sebagai perantara antara klien dan server")
]
t3_files = [".exe (Executable)", "ISO (Disk Image)", ".pdf (Dokumen)", ".apk (Android Package)", "Firmware Update", ".zip (Arsip)", "Source Code", "Database Backup", "Script (.sh / .bat)", "Konfigurasi (.json / .yaml)"]

# --- TIER 4 (Level 31-40) ---
t4_vulns = [
    ("SQL Injection", "membaca atau memodifikasi database"),
    ("Cross-Site Scripting (XSS)", "mengeksekusi script berbahaya di browser korban"),
    ("Cross-Site Request Forgery (CSRF)", "memaksa korban melakukan aksi yang tidak diinginkan"),
    ("SSRF", "memaksa server mengakses jaringan internal"),
    ("Local File Inclusion (LFI)", "membaca file sensitif di server (/etc/passwd)"),
    ("Insecure Direct Object Reference (IDOR)", "mengakses data milik pengguna lain dengan memanipulasi ID"),
    ("Command Injection", "mengeksekusi perintah OS langsung di server"),
    ("XML External Entity (XXE)", "membaca file sistem menggunakan parsing XML yang rentan"),
    ("Directory Traversal", "mengakses direktori di luar root web"),
    ("Security Misconfiguration", "mengeksploitasi konfigurasi default atau error verbose")
]
t4_threats = ["Malware Traffic", "DDoS", "Brute Force", "Port Scan", "Exploit Attempt"]
t4_net_attacks = [
    ("ARP Spoofing", "memetakan IP gateway ke MAC Address penyerang"),
    ("DNS Cache Poisoning", "mengarahkan domain ke IP server palsu"),
    ("SYN Flood", "menghabiskan resource server dengan koneksi setengah terbuka"),
    ("MAC Flooding", "memenuhi tabel CAM switch agar menjadi hub"),
    ("BGP Hijacking", "membelokkan rute trafik internet global")
]
t4_access = [
    ("RBAC (Role-Based)", "peran atau jabatan dalam organisasi"),
    ("MAC (Mandatory)", "label klasifikasi keamanan dan clearance"),
    ("DAC (Discretionary)", "kebijakan yang ditentukan oleh pemilik resource"),
    ("ABAC (Attribute-Based)", "kombinasi atribut user, resource, dan lingkungan"),
    ("RuBAC (Rule-Based)", "aturan spesifik seperti jam akses atau lokasi")
]
t4_evasion = ["Polymorphism", "Metamorphism", "Obfuscation", "Packing", "Rootkit hooking", "Process Hollowing", "DLL Injection", "Living off the Land (LotL)", "Anti-Debugging", "Fileless execution (in-memory)"]

# --- TIER 5 (Level 41-50) ---
t5_kill_chain = [
    ("Reconnaissance", "pengumpulan informasi target (OSINT)"),
    ("Weaponization", "menggabungkan exploit dengan backdoor payload"),
    ("Delivery", "mengirimkan payload ke target (misal: email phishing)"),
    ("Exploitation", "mengeksekusi exploit untuk memicu kerentanan"),
    ("Installation", "menginstal malware/backdoor untuk persistensi"),
    ("Command and Control (C2)", "membangun komunikasi dari sistem korban ke server penyerang"),
    ("Actions on Objectives", "mencuri data (exfiltration) atau merusak sistem")
]
t5_tools = [("Ghidra", "disassembly dan dekompilasi binary"), ("OllyDbg", "debugging aplikasi 32-bit di Windows"), ("Wireshark", "analisis paket jaringan tingkat lanjut"), ("Metasploit", "framework eksploitasi"), ("Radare2", "reverse engineering berbasis command line")]
t5_crypto_attacks = [
    ("Birthday Attack", "mencari kolisi (collision) pada fungsi hash"),
    ("Known-Plaintext Attack", "menganalisis kriptografi saat sebagian plaintext sudah diketahui"),
    ("Chosen-Ciphertext Attack", "menganalisis sistem dekripsi dengan menyuplai ciphertext khusus"),
    ("Side-Channel Attack", "mengeksploitasi informasi fisik (seperti konsumsi daya) dari perangkat"),
    ("Downgrade Attack", "memaksa penggunaan protokol enkripsi versi lama yang rentan")
]
t5_anomalies = ["Login sukses dari dua benua berbeda dalam waktu 5 menit", "Trafik outbound SSH yang besar di luar jam kerja", "Pembuatan akun admin baru secara tidak terduga", "Akses ke banyak file secara berurutan dalam hitungan detik", "Koneksi ke IP yang masuk dalam daftar Threat Intelligence"]
t5_advanced_vulns = [
    ("Buffer Overflow", "implementasi ASLR dan DEP/NX Bit"),
    ("Use-After-Free", "pengelolaan memori dinamis yang ketat dan garbage collection"),
    ("Format String Vulnerability", "menghindari fungsi format seperti printf() dengan input eksternal"),
    ("Integer Overflow", "validasi batas nilai dan tipe data yang sesuai"),
    ("Race Condition (TOC/TOU)", "penggunaan locks (mutex) atau operasi atomik")
]

for level in range(1, 51):
    tier = (level - 1) // 10 + 1
    idx = (level - 1) % 10
    
    level_qs = []
    for q_idx in range(5):
        # Determine logic based on Tier
        q_text = ""
        opts = []
        ans = 0
        exp = ""
        
        if tier == 1:
            if q_idx == 0:
                q_text = f"Manakah password yang paling aman jika kamu menggunakan platform {t1_platforms[idx]}?"
                opts = ["password123", f"{t1_platforms[idx].lower()}123", "P@ssw0rd123!", "tanggal lahir"]
                random.shuffle(opts)
                ans = opts.index("P@ssw0rd123!")
                exp = "Password aman menggunakan kombinasi huruf, angka, dan karakter spesial."
            elif q_idx == 1:
                q_text = f"Kamu menerima email dari {t1_senders[idx]} meminta {t1_requests[idx]}. Apa tindakanmu?"
                opts = ["Balas segera", "Abaikan dan hapus", "Klik link di dalamnya", "Forward ke teman"]
                random.shuffle(opts)
                ans = opts.index("Abaikan dan hapus")
                exp = "Pihak resmi tidak pernah meminta informasi sensitif via email tak terduga."
            elif q_idx == 2:
                q_text = f"Saat mendaftar di {t1_platforms[idx]}, sebaiknya kamu menggunakan Autentikasi Dua Faktor (2FA) berupa..."
                opts = ["Aplikasi Authenticator (OTP)", "Hanya password", "Pertanyaan keamanan 'Siapa nama hewan peliharaan?'", "Menulis sandi di kertas"]
                random.shuffle(opts)
                ans = opts.index("Aplikasi Authenticator (OTP)")
                exp = "Aplikasi Authenticator jauh lebih aman daripada sekadar password atau pertanyaan keamanan."
            elif q_idx == 3:
                q_text = f"Data mana yang sebaiknya TIDAK kamu bagikan secara publik di profil {t1_socials[idx]} mu?"
                opts = ["Foto makanan", "Film favorit", "Hobi", "Nomor Induk Kependudukan (NIK)"]
                random.shuffle(opts)
                ans = opts.index("Nomor Induk Kependudukan (NIK)")
                exp = "NIK dapat disalahgunakan untuk penipuan identitas atau meminjam pinjol ilegal."
            elif q_idx == 4:
                q_text = f"Ciri utama dari website phishing yang menargetkan {t1_targets[idx]} adalah..."
                opts = ["URL domainnya sedikit berbeda (typo)", "Desainnya jelek", "Loadingnya lambat", "Berada di halaman 1 Google"]
                random.shuffle(opts)
                ans = opts.index("URL domainnya sedikit berbeda (typo)")
                exp = "Website phishing sering menggunakan nama domain yang sangat mirip dengan aslinya (typosquatting)."
        
        elif tier == 2:
            if q_idx == 0:
                q_text = f"Saat menggunakan WiFi publik di {t2_locations[idx]}, aktivitas apa yang paling berisiko?"
                opts = ["Membuka m-Banking", "Membaca berita", "Menonton YouTube", "Bermain game offline"]
                random.shuffle(opts)
                ans = opts.index("Membuka m-Banking")
                exp = "WiFi publik sangat rentan terhadap penyadapan lalu lintas jaringan (sniffing)."
            elif q_idx == 1:
                malware = t2_malware_actions[idx]
                q_text = f"Jenis malware yang {malware[0]} disebut..."
                opts = [malware[1], "Antivirus", "Firewall", "Router"]
                random.shuffle(opts)
                ans = opts.index(malware[1])
                exp = f"Itulah definisi dari {malware[1]}."
            elif q_idx == 2:
                social = t2_social_methods[idx]
                q_text = f"Seorang penyerang {social[0]}. Ini adalah contoh dari..."
                opts = [social[1], "Hacking Jaringan", "Kriptografi", "Programming"]
                random.shuffle(opts)
                ans = opts.index(social[1])
                exp = f"{social[1]} adalah salah satu teknik Social Engineering."
            elif q_idx == 3:
                q_text = "Kamu melihat peringatan virus acak muncul saat mengunjungi sebuah situs. Langkah pertama adalah..."
                opts = ["Tutup tab/browser", "Klik tombol 'Bersihkan Sekarang'", "Install aplikasi yang disarankan", "Masukkan email"]
                random.shuffle(opts)
                ans = opts.index("Tutup tab/browser")
                exp = "Itu biasanya pop-up scareware. Jangan pernah mengklik peringatan palsu."
            elif q_idx == 4:
                q_text = f"Mengapa menggunakan VPN saat di jaringan publik {t2_locations[idx]} itu penting?"
                opts = ["Mengenksripsi koneksi dari penyadap", "Mempercepat internet", "Mendapat akses VIP", "Membersihkan virus"]
                random.shuffle(opts)
                ans = opts.index("Mengenksripsi koneksi dari penyadap")
                exp = "VPN membuat terowongan terenkripsi sehingga trafik tidak bisa dibaca oleh peretas di jaringan yang sama."
                
        elif tier == 3:
            if q_idx == 0:
                proto = t3_protocols[idx]
                q_text = f"Protokol {proto[0]} umumnya beroperasi pada port..."
                opts = [proto[1], "8080", "123", "4444"]
                random.shuffle(opts)
                ans = opts.index(proto[1])
                exp = f"Port default untuk {proto[0]} adalah {proto[1]}."
            elif q_idx == 1:
                cia = t3_cia[idx % 3]
                q_text = f"Konsep {cia[0]} dalam keamanan informasi berfokus pada..."
                opts = [cia[1], "meningkatkan kecepatan jaringan", "memperbarui hardware", "menghapus akun lama"]
                random.shuffle(opts)
                ans = opts.index(cia[1])
                exp = f"Dalam CIA Triad, {cia[0]} bertujuan {cia[1]}."
            elif q_idx == 2:
                algo = t3_algorithms[idx]
                q_text = f"Algoritma enkripsi {algo[0]} termasuk dalam kategori kriptografi..."
                opts = [algo[1], "Hashing", "Encoding", "Steganography"]
                random.shuffle(opts)
                ans = opts.index(algo[1])
                exp = f"{algo[0]} adalah algoritma {algo[1]}."
            elif q_idx == 3:
                fw = t3_firewalls[idx % 5]
                q_text = f"Tujuan/metode utama dari {fw[0]} adalah..."
                opts = [fw[1], "mendeteksi virus lokal", "mempercepat koneksi internet", "mengelola password"]
                random.shuffle(opts)
                ans = opts.index(fw[1])
                exp = f"{fw[0]} bekerja dengan {fw[1]}."
            elif q_idx == 4:
                q_text = f"Untuk memverifikasi integritas {t3_files[idx]} yang diunduh, kita harus memeriksa nilai..."
                opts = ["Hash (seperti SHA-256)", "Ukuran byte", "Tanggal rilis", "Nama pembuat"]
                random.shuffle(opts)
                ans = opts.index("Hash (seperti SHA-256)")
                exp = "Nilai hash memastikan file tidak diubah sediktpun sejak dirilis."

        elif tier == 4:
            if q_idx == 0:
                vuln = t4_vulns[idx]
                q_text = f"Kerentanan {vuln[0]} memungkinkan penyerang untuk..."
                opts = [vuln[1], "merusak hardware fisik", "meningkatkan kecepatan internet", "membersihkan log sistem"]
                random.shuffle(opts)
                ans = opts.index(vuln[1])
                exp = f"Eksploitasi {vuln[0]} pada dasarnya menyebabkan penyerang bisa {vuln[1]}."
            elif q_idx == 1:
                q_text = f"Perbedaan utama antara IDS dan IPS dalam merespons {t4_threats[idx % 5]} adalah..."
                opts = ["IPS secara aktif memblokir, IDS hanya memberi peringatan", "IDS memblokir, IPS membiarkan", "IDS lebih cepat dari IPS", "Tidak ada bedanya"]
                random.shuffle(opts)
                ans = opts.index("IPS secara aktif memblokir, IDS hanya memberi peringatan")
                exp = "Intrusion Prevention System (IPS) melakukan tindakan preventif, IDS hanya deteksi."
            elif q_idx == 2:
                atk = t4_net_attacks[idx % 5]
                q_text = f"Serangan {atk[0]} bekerja dengan cara..."
                opts = [atk[1], "mengirim email phising", "mengeksploitasi SQL", "mengenkripsi file"]
                random.shuffle(opts)
                ans = opts.index(atk[1])
                exp = f"Mekanisme utama {atk[0]} adalah {atk[1]}."
            elif q_idx == 3:
                acc = t4_access[idx % 5]
                q_text = f"Dalam model kontrol akses {acc[0]} (Access Control), hak akses ditentukan berdasarkan..."
                opts = [acc[1], "kecepatan internet", "jenis browser", "jumlah kuota"]
                random.shuffle(opts)
                ans = opts.index(acc[1])
                exp = f"Model {acc[0]} sangat bergantung pada {acc[1]}."
            elif q_idx == 4:
                q_text = f"Teknik {t4_evasion[idx]} umumnya digunakan oleh malware untuk..."
                opts = ["Menghindari deteksi dari antivirus / EDR", "Mempercantik antarmuka", "Memperbaiki sistem", "Membuat backup"]
                random.shuffle(opts)
                ans = opts.index("Menghindari deteksi dari antivirus / EDR")
                exp = f"{t4_evasion[idx]} adalah teknik evasion (penghindaran deteksi)."
                
        elif tier == 5:
            if q_idx == 0:
                kc = t5_kill_chain[idx % 7]
                q_text = f"Tahap {kc[0]} dalam Cyber Kill Chain melibatkan aktivitas..."
                opts = [kc[1], "mengganti hardware server", "membuat laporan tahunan", "mengupdate OS"]
                random.shuffle(opts)
                ans = opts.index(kc[1])
                exp = f"Tahap {kc[0]} berfokus pada {kc[1]}."
            elif q_idx == 1:
                tool = t5_tools[idx % 5]
                q_text = f"Dalam industri keamanan siber, alat '{tool[0]}' sering digunakan untuk..."
                opts = [tool[1], "membuat grafis 3D", "menulis dokumen teks", "mengirim email spam"]
                random.shuffle(opts)
                ans = opts.index(tool[1])
                exp = f"{tool[0]} adalah standar industri untuk {tool[1]}."
            elif q_idx == 2:
                catk = t5_crypto_attacks[idx % 5]
                q_text = f"Serangan {catk[0]} pada algoritma kriptografi bekerja dengan cara..."
                opts = [catk[1], "menghancurkan hard disk", "mencuri password wifi", "menelpon korban"]
                random.shuffle(opts)
                ans = opts.index(catk[1])
                exp = f"{catk[0]} adalah teknik serangan kriptografi dimana penyerang {catk[1]}."
            elif q_idx == 3:
                q_text = f"Analisis log SIEM mendeteksi aktivitas anomali berupa: '{t5_anomalies[idx % 5]}'. Ini dapat mengindikasikan..."
                opts = ["Kemungkinan Compromise atau Serangan aktif", "Komputer sedang update", "Jaringan beroperasi normal", "Koneksi internet sangat stabil"]
                random.shuffle(opts)
                ans = opts.index("Kemungkinan Compromise atau Serangan aktif")
                exp = "Aktivitas anomali seperti ini di SIEM memerlukan investigasi Incident Response segera."
            elif q_idx == 4:
                adv = t5_advanced_vulns[idx % 5]
                q_text = f"Mitigasi teknis yang paling efektif terhadap kerentanan {adv[0]} meliputi..."
                opts = [adv[1], "menggunakan antivirus gratis", "mengganti password tiap hari", "mematikan komputer"]
                random.shuffle(opts)
                ans = opts.index(adv[1])
                exp = f"Untuk mencegah {adv[0]}, developer harus memastikan {adv[1]}."

        level_qs.append({
            "id": id_counter,
            "question": q_text,
            "options": opts,
            "correctAnswerIndex": ans,
            "explanation": exp
        })
        id_counter += 1
        
    levels.append({
        "level": level,
        "questions": level_qs
    })

data = {"levels": levels}

os.makedirs("assets/data", exist_ok=True)
with open("assets/data/questions.json", "w") as f:
    json.dump(data, f, indent=2)

print("Berhasil membuat 250 pertanyaan untuk 50 level.")
