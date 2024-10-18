import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<dynamic> infoList = [];
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInfo();
  }

  Future<void> fetchInfo() async {
    final response = await http.get(Uri.parse('https://hayy.my.id/rilians/info.php'));
    if (response.statusCode == 200) {
      setState(() {
        infoList = json.decode(response.body);
      });
    } else {
      throw Exception('Gagal memuat data informasi');
    }
  }

  Future<void> addInfo() async {
    final response = await http.post(
      Uri.parse('https://hayy.my.id/rilians/info.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'judul_info': _judulController.text,
        'isi_info': _isiController.text,
        'tgl_post_info': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      fetchInfo();
      _judulController.clear();
      _isiController.clear();
    } else {
      throw Exception('Gagal menambahkan informasi');
    }
  }

  Future<void> editInfo(String id) async {
    final response = await http.put(
      Uri.parse('https://hayy.my.id/rilians/info.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'kd_info': id,
        'judul_info': _judulController.text,
        'isi_info': _isiController.text,
        'tgl_post_info': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      fetchInfo();
      _judulController.clear();
      _isiController.clear();
    } else {
      throw Exception('Gagal mengedit informasi');
    }
  }

  Future<void> deleteInfo(String id) async {
    final response = await http.delete(
      Uri.parse('https://hayy.my.id/rilians/info.php?kd_info=$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      fetchInfo();
    } else {
      throw Exception('Gagal menghapus informasi');
    }
  }

  void _showAddInfoDialog() {
    _judulController.clear();
    _isiController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildInfoDialog('Tambah Informasi Baru', () {
          addInfo();
          Navigator.of(context).pop();
        });
      },
    );
  }

  void _showEditInfoDialog(String id, String judul, String isi) {
    _judulController.text = judul;
    _isiController.text = isi;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildInfoDialog('Edit Informasi', () {
          editInfo(id);
          Navigator.of(context).pop();
        });
      },
    );
  }

  Widget _buildInfoDialog(String title, VoidCallback onSave) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1565C0))),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: "Judul Informasi",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _isiController,
              decoration: InputDecoration(
                labelText: "Isi Informasi",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
                ),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Batal', style: TextStyle(color: Color(0xFF1565C0))),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onSave,
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          content: const Text('Apakah Anda yakin ingin menghapus informasi ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Color(0xFF1565C0))),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
              onPressed: () {
                deleteInfo(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Informasi Sekolah', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
      ),
      body: infoList.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: infoList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      infoList[index]['judul_info'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1565C0)),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Diposting pada: ${infoList[index]['tgl_post_info']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          infoList[index]['isi_info'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      OverflowBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit, color: Color(0xFF1565C0)),
                            label: const Text('Edit', style: TextStyle(color: Color(0xFF1565C0))),
                            onPressed: () {
                              _showEditInfoDialog(
                                infoList[index]['kd_info'],
                                infoList[index]['judul_info'],
                                infoList[index]['isi_info'],
                              );
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              _showDeleteConfirmationDialog(infoList[index]['kd_info']);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddInfoDialog,
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
