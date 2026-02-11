Refleksi Penerapan SRP

Penerapan prinsip Single Responsibility Principle (SRP) sangat membantu dalam pengembangan fitur History Logger. 
Karena logika aplikasi sudah dipisahkan ke dalam Controller, penambahan fitur History Logger hanya dilakukan dengan memodifikasi Controller tanpa mengubah struktur tampilan secara signifikan.
Sementara itu, perubahan tampilan seperti pewarnaan teks dan dialog konfirmasi dapat dilakukan sepenuhnya di bagian View,
Meskipun perlu waktu untuk benar-benar memahami sistem SRP, Pemisahan ini membuat kode lebih terstruktur, mudah dibaca, mudah dipahami, dan meminimalkan risiko bug saat fitur baru ditambahkan.
