import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  Future<List<dynamic>> fetchAgenda() async {
    final response =
        await http.get(Uri.parse('https://hayy.my.id/rilians/agenda.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data agenda');
    }
  }

  Future<void> addAgenda(String judul, String isi, DateTime tgl, String status,
      String petugas) async {
    final response = await http.post(
      Uri.parse('https://hayy.my.id/rilians/agenda.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'judul_agenda': judul,
        'isi_agenda': isi,
        'tgl_agenda': tgl.toIso8601String(),
        'status_agenda': status,
        'kd_petugas': petugas,
        'tgl_post_agenda': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menambahkan agenda');
    }
  }

  Future<void> editAgenda(String id, String judul, String isi, DateTime tgl,
      String status, String petugas) async {
    final response = await http.put(
      Uri.parse('https://hayy.my.id/rilians/agenda.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'kd_agenda': id,
        'judul_agenda': judul,
        'isi_agenda': isi,
        'tgl_agenda': tgl.toIso8601String(),
        'status_agenda': status,
        'kd_petugas': petugas,
        'tgl_post_agenda': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengedit agenda');
    }
  }

  Future<void> deleteAgenda(String id) async {
    final response = await http.delete(
      Uri.parse('https://hayy.my.id/rilians/agenda.php?kd_agenda=$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus agenda');
    }
  }

  final TextEditingController judulController = TextEditingController();
  final TextEditingController isiController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController petugasController = TextEditingController();
  DateTime? selectedDate;
  bool isEditMode = false;
  Map<String, dynamic>? currentEditData;

  void startEditMode(Map<String, dynamic> data) {
    setState(() {
      isEditMode = true;
      currentEditData = data;
      judulController.text = data['judul_agenda'];
      isiController.text = data['isi_agenda'];
      statusController.text = data['status_agenda'];
      petugasController.text = data['kd_petugas'];
      selectedDate = DateTime.parse(data['tgl_agenda']);
    });
  }

  void resetForm() {
    setState(() {
      isEditMode = false;
      currentEditData = null;
      judulController.clear();
      isiController.clear();
      statusController.clear();
      petugasController.clear();
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Agenda Sekolah'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditMode ? 'Edit Agenda' : 'Tambah Agenda Baru',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: judulController,
                      decoration: InputDecoration(
                        labelText: 'Judul Agenda',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.title, color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: isiController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Isi Agenda',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.description, color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: statusController,
                      decoration: InputDecoration(
                        labelText: 'Status Agenda',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.flag, color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: petugasController,
                      decoration: InputDecoration(
                        labelText: 'Petugas',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text(
                        selectedDate == null
                            ? 'Pilih Tanggal Agenda'
                            : 'Tanggal Agenda: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(color: Colors.indigo),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: Colors.indigo),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedDate != null) {
                            if (isEditMode && currentEditData != null) {
                              await editAgenda(
                                currentEditData!['kd_agenda'],
                                judulController.text,
                                isiController.text,
                                selectedDate!,
                                statusController.text,
                                petugasController.text,
                              );
                            } else {
                              await addAgenda(
                                judulController.text,
                                isiController.text,
                                selectedDate!,
                                statusController.text,
                                petugasController.text,
                              );
                            }
                            resetForm();
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          isEditMode ? 'Perbarui Agenda' : 'Tambah Agenda',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<dynamic>>(
                future: fetchAgenda(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak Ada Agenda Tersedia'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            data['judul_agenda'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.indigo,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(data['isi_agenda']),
                              const SizedBox(height: 8),
                              Text(
                                'Tanggal: ${data['tgl_agenda']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.indigo),
                                onPressed: () => startEditMode(data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await deleteAgenda(data['kd_agenda']);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
