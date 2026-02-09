Refleksi Penerapan SRP

Penerapan prinsip Single Responsibility Principle (SRP) sangat membantu dalam pengembangan fitur History Logger. 
Karena logika aplikasi sudah dipisahkan ke dalam Controller, penambahan fitur riwayat hanya dilakukan dengan memodifikasi Controller tanpa mengubah struktur tampilan secara signifikan.
Sementara itu, perubahan tampilan seperti pewarnaan teks dan dialog konfirmasi dapat dilakukan sepenuhnya di bagian View.`` 
Pemisahan ini membuat kode lebih terstruktur, mudah dipahami, dan meminimalkan risiko bug saat fitur baru ditambahkan.
