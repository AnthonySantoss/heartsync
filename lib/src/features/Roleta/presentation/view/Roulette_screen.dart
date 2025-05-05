import 'package:flutter/material.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:async';
import 'dart:math';

class Activity {
  final String name;
  final String blockTime;

  const Activity({required this.name, required this.blockTime});
}

class RouletteScreen extends StatefulWidget {
  final List<Activity> initialActivities;
  final String? imageUrl;
  final String dayUsed;

  const RouletteScreen({
    super.key,
    this.initialActivities = const [
      Activity(name: 'Filme', blockTime: '1 hora'),
      Activity(name: 'Jogar...', blockTime: '1h30min'),
      Activity(name: 'Fazer...', blockTime: '2 horas'),
      Activity(name: 'Assistir...', blockTime: '1 hora'),
      Activity(name: 'Domir...', blockTime: '30 minutos'),
    ],
    this.imageUrl,
    this.dayUsed = '3',
  });

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> {
  List<Activity> activities = [];
  List<Activity> outdoorActivities = const [
    Activity(name: 'Caminhar', blockTime: '1 hora'),
    Activity(name: 'Corrida', blockTime: '1h30min'),
    Activity(name: 'Piquenique', blockTime: '2 horas'),
    Activity(name: 'Ciclismo', blockTime: '1 hora'),
    Activity(name: 'Passeio', blockTime: '30 minutos'),
  ];
  int selectedIndex = 0;
  bool isSpinning = false;
  final StreamController<int> _controller = StreamController<int>();
  String selectedCategory = 'Dentro de Casa';

  @override
  void initState() {
    super.initState();
    activities = List.from(widget.initialActivities);
    _controller.add(selectedIndex);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void addActivity() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        String newTime = '';
        return AlertDialog(
          backgroundColor: const Color(0xFF210E45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Adicionar Tarefa',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nome da Tarefa',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  newName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tempo de Bloqueio (ex.: 1 hora)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  newTime = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4D3192),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                if (newName.isNotEmpty && newTime.isNotEmpty) {
                  setState(() {
                    activities.add(Activity(name: newName, blockTime: newTime));
                  });
                  print('Nova tarefa adicionada: $newName, $newTime');
                }
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4D3192),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Adicionar',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void editActivity(int index) {
    String editName = activities[index].name;
    String editTime = activities[index].blockTime;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF210E45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Editar Tarefa',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nome da Tarefa',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                controller: TextEditingController(text: editName),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  editName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tempo de Bloqueio (ex.: 1 hora)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                controller: TextEditingController(text: editTime),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  editTime = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4D3192),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                if (editName.isNotEmpty && editTime.isNotEmpty) {
                  setState(() {
                    activities[index] = Activity(name: editName, blockTime: editTime);
                  });
                  print('Tarefa editada: $editName, $editTime');
                }
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4D3192),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void editActivityList() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF210E45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Editar Lista de Tarefas',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFF08050F),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(
                      activities[index].name,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Bloqueio: ${activities[index].blockTime}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        editActivity(index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4D3192),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Fechar',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      print('Lista de tarefas atualizada: $activities');
    });
  }

  void spinWheel() {
    if (activities.isEmpty) return;
    setState(() {
      isSpinning = true;
      selectedIndex = Random().nextInt(activities.length);
      _controller.add(selectedIndex);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _showResultDialog(context);
      }
    });
  }

  void _showResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF210E45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Resultado da Roleta',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Atividade: ${activities[selectedIndex].name}\nTempo de Bloqueio: ${activities[selectedIndex].blockTime}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isSpinning = true;
                  selectedIndex = 0;
                  _controller.add(selectedIndex);
                  spinWheel();
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4D3192),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Girar Novamente',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Image.asset(
                        'lib/assets/images/Back.png',
                        width: 27,
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'lib/assets/images/sequencia.png',
                              width: 24,
                              height: 31,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.dayUsed,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFDBDBDB),
                        backgroundImage: widget.imageUrl != null
                            ? NetworkImage(widget.imageUrl!)
                            : null,
                        child: widget.imageUrl == null
                            ? const Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.white,
                        )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: 286,
                    height: 50,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF311469),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue!;
                                if (selectedCategory == 'Fora de Casa') {
                                  activities = List.from(outdoorActivities);
                                } else {
                                  activities = List.from(widget.initialActivities);
                                }
                              });
                            },
                            items: <String>['Dentro de Casa', 'Fora de Casa']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      value,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    if (value == 'Dentro de Casa')
                                      const Icon(Icons.home, color: Colors.white, size: 16)
                                    else
                                      const Icon(Icons.directions_walk, color: Colors.white, size: 16),
                                  ],
                                ),
                              );
                            }).toList(),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            underline: const SizedBox(),
                            dropdownColor: const Color(0xFF130B26),
                            borderRadius: BorderRadius.circular(20),
                            isExpanded: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: FloatingActionButton(
                            onPressed: addActivity,
                            backgroundColor: const Color(0xFF210E45),
                            shape: const CircleBorder(),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF210E45),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              onPressed: editActivityList,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    Center(
                      child: Container(
                        height: 419,
                        width: 419,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF7D48FE),
                            width: 5,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            height: 405,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                FortuneWheel(
                                  selected: _controller.stream,
                                  animateFirst: false,
                                  duration: const Duration(seconds: 3),
                                  indicators: [
                                    const FortuneIndicator(
                                      alignment: Alignment.topCenter,
                                      child: TriangleIndicator(
                                        width: 30,
                                        height: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                  items: activities.map((activity) {
                                    return FortuneItem(
                                      child: Text(
                                        activity.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: FortuneItemStyle(
                                        color: activities.indexOf(activity) % 2 == 0
                                            ? const Color(0xFF08050E)
                                            : const Color(0xFF08050E),
                                        borderColor: const Color(0xFF4D3192),
                                        borderWidth: 5,
                                      ),
                                    );
                                  }).toList(),
                                  onAnimationEnd: () {
                                    setState(() {
                                      isSpinning = false;
                                    });
                                  },
                                ),
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4D3192),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: (isSpinning || activities.isEmpty) ? null : spinWheel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D3192),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Girar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  selectedIndex == 0 && !isSpinning ? '' : '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}