import 'package:flutter/material.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';


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
      Activity(name: 'Filme', blockTime: '01:00'),
      Activity(name: 'Jogar', blockTime: '01:30'),
      Activity(name: 'Fazer exercícios', blockTime: '02:00'),
      Activity(name: 'Assistir série', blockTime: '01:00'),
      Activity(name: 'Dormir', blockTime: '00:30'),
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
    Activity(name: 'Caminhar', blockTime: '01:00'),
    Activity(name: 'Corrida', blockTime: '01:30'),
    Activity(name: 'Piquenique', blockTime: '02:00'),
    Activity(name: 'Ciclismo', blockTime: '01:00'),
    Activity(name: 'Passeio', blockTime: '00:30'),
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

  String _formatDisplayTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return time;

    try {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      if (hours > 0 && minutes > 0) {
        return '${hours}h${minutes.toString().padLeft(2, '0')}min';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}min';
      }
    } catch (e) {
      return time;
    }
  }

  bool _isValidTime(String time) {
    return RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time);
  }

  void addActivity() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        String newTime = '';
        final timeController = TextEditingController();

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
                onChanged: (value) => newName = value,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Tempo (HH:MM)',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Ex: 01:30 para 1h30min',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.digitsOnly,
                  _TimeInputFormatter(),
                ],
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  if (value.length == 5) {
                    newTime = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
                if (newName.isNotEmpty && newTime.isNotEmpty && _isValidTime(newTime)) {
                  setState(() {
                    activities.add(Activity(name: newName, blockTime: newTime));
                  });
                  Navigator.pop(context);
                }
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
    final timeController = TextEditingController(text: editTime);

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
                onChanged: (value) => editName = value,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Tempo (HH:MM)',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Ex: 01:30 para 1h30min',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.digitsOnly,
                  _TimeInputFormatter(),
                ],
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  if (value.length == 5) {
                    editTime = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
                if (editName.isNotEmpty && editTime.isNotEmpty && _isValidTime(editTime)) {
                  setState(() {
                    activities[index] = Activity(name: editName, blockTime: editTime);
                  });
                  Navigator.pop(context);
                }
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
          backgroundColor: const Color(0xFF08050F),
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
                  color: const Color(0xFF210E45),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(
                      activities[index].name,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Bloqueio: ${_formatDisplayTime(activities[index].blockTime)}',
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
              onPressed: () => Navigator.pop(context),
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
    );
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
            'Atividade do dia',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activities[selectedIndex].name,
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Tempo restante',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _formatDisplayTime(activities[selectedIndex].blockTime),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF4D3192),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Manter Tarefa',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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
                padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
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
                child: Visibility(
                  visible: !isSpinning, // Inverte o valor - mostra quando NÃO estiver girando
                  child: ElevatedButton(
                    onPressed: spinWheel,
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

class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    if (text.length >= 3) {
      text = '${text.substring(0, 2)}:${text.substring(2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}