
import 'package:crud_mongodb/insert_pet_screern.dart';
import 'package:crud_mongodb/mongo_service.dart';
import 'package:crud_mongodb/pet_model.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  List<PetModel> pets = [];
  late TextEditingController _nameController;
  late TextEditingController _typeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _typeController = TextEditingController();
    _fetchPets();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _fetchPets() async {
    pets = await MongoService().getPets();
    setState(() {});
  }

  void _showEditDialog(PetModel pet) {
    _nameController.text = pet.name;
    _typeController.text = pet.type;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Editar mascota'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    pet.name = _nameController.text;
                    pet.type = _typeController.text;
                    _updatePet(pet);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Actualizar')),
            ],
          );
        });
  }

  void _updatePet(PetModel pet) async {
    await MongoService().updatePet(pet);
    _fetchPets();
  }

  void _deletePet(mongo.ObjectId id) async {
    await MongoService().deletePet(id);
    _fetchPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MongoDB Crud'),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InsertPetScreen(),
                    ),
                );
                _fetchPets();
              },
              child: const Icon(
                Icons.add,
                size: 26.0,
              ),
            ),
          ],
        ),
        body: ListView.builder(
            itemCount: pets.length,
            itemBuilder: (content, index) {
              var pet = pets[index];
              return ListTile(
                title: Text(pet.name),
                subtitle: Text(pet.type),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => _showEditDialog(pet),
                        icon: const Icon(Icons.edit)),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deletePet(pet.id),
                    )
                  ],
                ),
              );
            }));
  }
}