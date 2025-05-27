import 'package:flutter/material.dart';
import 'package:heartsync/servico/api_service.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:get_it/get_it.dart';

class Activity {
  final String name;
  final String blockTime;

  const Activity({required this.name, required this.blockTime});
}

class RouletteScreen extends StatefulWidget {
  final List<Activity> initialActivities;
  final String? imageUrl;
  final int userId;

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
    required this.userId,
  });

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> with WidgetsBindingObserver {
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
  bool isTimerRunning = false;
  int timerSeconds = 0;
  Timer? _timer;
  final StreamController<int> _controller = StreamController<int>();
  String selectedCategory = 'Dentro de Casa';
  int streakCount = 0;
  final DatabaseHelper _databaseHelper = GetIt.instance<DatabaseHelper>();
  final ApiService _apiService = GetIt.instance<ApiService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    activities = List.from(widget.initialActivities);
    _controller.add(selectedIndex);
    _loadStreak();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && isTimerRunning) {
      _resetTimer();
    }
  }

  Future<void> _loadStreak() async {
    try {
      final streakData = await _apiService.getStreak(widget.userId);
      setState(() {
        streakCount = streakData; // Diretamente o int retornado
      });
    } catch (e) {
      print('Erro ao carregar streak: $e');
      final localStreak = await _databaseHelper.getStreakCount(widget.userId);
      setState(() {
        streakCount = localStreak;
      });
    }
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

  void _startTimer(String blockTime) {
    final parts = blockTime.split(':');
    if (parts.length != 2) return;

    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    timerSeconds = hours * 3600 + minutes * 60;

    setState(() {
      isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds > 0) {
        setState(() {
          timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          isTimerRunning = false;
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      isTimerRunning = false;
      timerSeconds = 0;
    });
  }

  Future<void> _incrementStreak() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastStreakDate = await _databaseHelper.getLastStreakDate(widget.userId);
      int newStreak = streakCount;

      if (lastStreakDate == today) {
        print('Já girou a roleta hoje.');
        return;
      }

      if (lastStreakDate != null) {
        final lastDate = DateTime.parse(lastStreakDate);
        final difference = DateTime.now().difference(lastDate).inDays;
        if (difference == 1) {
          newStreak++;
        } else if (difference > 1) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      await _databaseHelper.updateStreakCount(
        widget.userId,
        newStreak,
        lastStreakDate: today,
      );
      await _apiService.updateStreak(widget.userId, newStreak, lastStreakDate: today);

      setState(() {
        streakCount = newStreak;
      });
    } catch (e) {
      print('Erro ao incrementar streak: $e');
    }
  }

  Future<bool> _canSpinToday() async {
    try {
      return !(await _databaseHelper.hasUsedRouletteToday(widget.userId));
    } catch (e) {
      print('Erro ao verificar giro de hoje: $e');
      return false;
    }
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
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Adicionar Tarefa',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
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
                style: TextStyle(color: Colors.white),
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
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
          backgroundColor: const Color(0xFF08050E),
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
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveRouletteActivity() async {
    final now = DateTime.now();
    final dataRoleta = now.toIso8601String().split('T')[0];
    final proximaRoleta = now.add(Duration(days: 1)).toIso8601String().split('T')[0];
    final atividade = activities[selectedIndex].name;
    final blockTime = activities[selectedIndex].blockTime;

    try {
      await _databaseHelper.insertRoulette(
        idUsuario: widget.userId,
        dataRoleta: dataRoleta,
        atividade: atividade,
        blockTime: blockTime,
        proximaRoleta: proximaRoleta,
      );
      await _apiService.saveRouletteActivity(
        userId: widget.userId,
        dataRoleta: dataRoleta,
        atividade: atividade,
        blockTime: blockTime,
        proximaRoleta: proximaRoleta,
      );
      await _incrementStreak();
    } catch (e) {
      print('Erro ao salvar atividade da roleta: $e');
    }
  }

  void spinWheel() async {
    if (activities.isEmpty) return;

    if (!(await _canSpinToday())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você já girou a roleta hoje! Tente novamente amanhã.')),
      );
      return;
    }

    setState(() {
      isSpinning = true;
      selectedIndex = Random().nextInt(activities.length);
      _controller.add(selectedIndex);
    });

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        _saveRouletteActivity();
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF210E45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Atividade do Dia',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activities[selectedIndex].name,
                style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Tempo de Bloqueio',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                _formatDisplayTime(activities[selectedIndex].blockTime),
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      spinWheel();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF4D3192),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Girar Novamente',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _startTimer(activities[selectedIndex].blockTime);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF4D3192),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Iniciar Tarefa',
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

  String _formatTimer(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        padding: EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context, true),
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
                            SizedBox(width: 8),
                            Text(
                              streakCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFDBDBDB),
                        backgroundImage: widget.imageUrl != null ? NetworkImage(widget.imageUrl!) : null,
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Erro ao carregar imagem de perfil: $exception');
                        },
                        child: widget.imageUrl == null
                            ? Icon(
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
              SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: 286,
                    height: 50,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFF311469),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue!;
                                activities = selectedCategory == 'Fora de Casa'
                                    ? List.from(outdoorActivities)
                                    : List.from(widget.initialActivities);
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
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      value == 'Dentro de Casa' ? Icons.home : Icons.directions_walk,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                            underline: SizedBox(),
                            dropdownColor: Color(0xFF130B26),
                            borderRadius: BorderRadius.circular(20),
                            isExpanded: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                            backgroundColor: Color(0xFF210E45),
                            shape: CircleBorder(),
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF210E45),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.more_vert, color: Colors.white),
                              onPressed: editActivityList,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        height: 419,
                        width: 419,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF7D48FE),
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
                                  duration: Duration(seconds: 3),
                                  indicators: [
                                    FortuneIndicator(
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: FortuneItemStyle(
                                        color: activities.indexOf(activity) % 2 == 0
                                            ? Color(0xFF08050E)
                                            : Color(0xFF08050E),
                                        borderColor: Color(0xFF4D3192),
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
                                  decoration: BoxDecoration(
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
              SizedBox(height: 20),
              Center(
                child: Visibility(
                  visible: !isSpinning,
                  child: ElevatedButton(
                    onPressed: isTimerRunning ? null : spinWheel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4D3192),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
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
              SizedBox(height: 20),
              if (isTimerRunning)
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF7D48FE), width: 5),
                    ),
                    child: Center(
                      child: Text(
                        _formatTimer(timerSeconds),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
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