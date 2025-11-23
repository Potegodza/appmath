import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'sound_service.dart';

// To use custom fonts like 'Mitr', you need to:
// 1. Add the google_fonts package to your pubspec.yaml:
//    dependencies:
//      google_fonts: ^6.2.1
// 2. Import it: import 'package:google_fonts/google_fonts.dart';
// 3. Use it in TextStyle: style: GoogleFonts.mitr(...)
// For this example, we'll use the default font.

// Logo configuration
const String logoPath = 'assets/IMAGE/LOGO.png';
const String learnButtonPath = 'assets/IMAGE/learn_button.png';
const String settingsButtonPath = 'assets/IMAGE/settings_button.png';
const String additionIconPath = 'assets/IMAGE/addition.png';
const String subtractionIconPath = 'assets/IMAGE/subtraction.png';
const String multiplicationIconPath = 'assets/IMAGE/multiplication.png';
const String divisionIconPath = 'assets/IMAGE/division.png';
const bool useLogo = true; // ✅ เปิดใช้งาน Logo แล้ว!

void main() {
  runApp(const MathKidsApp());
}

class MathKidsApp extends StatelessWidget {
  const MathKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Kid\'s 🐰',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFFF3E0), // ส้มอ่อนแบบแครอท
        fontFamily: 'Mitr', // Make sure to add this font to your project
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

// Enum to manage which screen is currently visible
enum AppScreen {
  splash,
  auth,
  signup,
  login,
  mainMenu,
  category,
  quiz,
  shapes,
  success,
  wrongAnswer,
  result,
  settings,
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  AppScreen _currentScreen = AppScreen.splash;
  String _currentQuizType = '';
  int _score = 0;
  int _questionCount = 0; // นับจำนวนข้อที่ตอบไปแล้ว
  static const int _totalQuestions = 5; // จำนวนข้อทั้งหมด
  Map<String, dynamic> _currentQuestion = {};
  int _wrongAnswer = 0; // เก็บคำตอบที่ผิด

  // Sound service
  final SoundService _soundService = SoundService();

  // Settings state
  bool _isSoundOn = true;
  bool _isMusicOn = true;
  bool _isTtsOn = true; // เสียงอ่านโจทย์

  @override
  void initState() {
    super.initState();
    // ตั้งค่าเสียงตามสถานะตั้งค่า
    _soundService.setSoundEnabled(_isSoundOn);
    _soundService.setTtsEnabled(_isTtsOn);
    // ตั้งค่าเพลงและเล่นเพลงพื้นหลังอัตโนมัติ (ถ้าเปิดเพลงอยู่)
    _soundService.setMusicEnabled(_isMusicOn);

    // Simulate loading and then move from splash screen
    Timer(const Duration(seconds: 3), () {
      _showScreen(AppScreen.auth);
    });
  }

  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }

  void _showScreen(AppScreen screen) {
    setState(() {
      _currentScreen = screen;
    });

    // เล่นเพลงพื้นหลังเมื่อเข้าสู่หน้าหลัก (ถ้าเปิดเพลงอยู่)
    if (screen == AppScreen.mainMenu && _isMusicOn) {
      _soundService.playBackgroundMusic();
    }
  }

  void _startQuiz(String type) {
    setState(() {
      _currentQuizType = type;
      _score = 0;
      _questionCount = 0; // รีเซ็ตจำนวนข้อ
      _wrongAnswer = 0; // รีเซ็ตคำตอบที่ผิด
      _generateQuestion();
      _currentScreen = AppScreen.quiz;
    });
  }

  void _generateQuestion() {
    final quiz = quizData[_currentQuizType]!;
    final questions = quiz['questions'] as List<Map<String, dynamic>>;
    final questionData = questions[Random().nextInt(questions.length)];

    final correctAnswer = questionData['a'] as int;
    Set<int> options = {correctAnswer};
    while (options.length < 4) {
      final randomOffset = Random().nextInt(11) - 5;
      int randomAnswer = correctAnswer + randomOffset;
      if (randomAnswer < 0) randomAnswer = 0;
      if (randomAnswer != correctAnswer) {
        options.add(randomAnswer);
      }
    }

    final optionsList = options.toList()..shuffle();

    setState(() {
      _currentQuestion = {
        'q': questionData['q'],
        'a': correctAnswer,
        'options': optionsList,
      };
    });

    // อ่านโจทย์ออกมาเป็นเสียง
    final questionText = questionData['q'] as String;
    _soundService.speakQuestion('$questionText = ?');
  }

  void _checkAnswer(int selectedAnswer) {
    setState(() {
      _questionCount++; // เพิ่มจำนวนข้อที่ตอบไปแล้ว
    });

    if (selectedAnswer == _currentQuestion['a']) {
      // เล่นเสียงตอบถูก
      _soundService.playSuccessSound();
      setState(() {
        _score++;
      });

      // ตรวจสอบว่าครบ 5 ข้อแล้วหรือยัง
      if (_questionCount >= _totalQuestions) {
        _showScreen(AppScreen.result);
      } else {
        _showScreen(AppScreen.success);
      }
    } else {
      // เล่นเสียงตอบผิด
      _soundService.playWrongSound();
      // เก็บคำตอบที่ผิดและแสดงหน้าตอบผิด
      setState(() {
        _wrongAnswer = selectedAnswer;
      });

      // ตรวจสอบว่าครบ 5 ข้อแล้วหรือยัง (ตอบผิดก็ยังนับเป็นข้อที่ตอบแล้ว)
      if (_questionCount >= _totalQuestions) {
        _showScreen(AppScreen.result);
      } else {
        _showScreen(AppScreen.wrongAnswer);
      }
    }
  }

  void _nextQuestion() {
    _generateQuestion();
    _showScreen(AppScreen.quiz);
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AppScreen.splash:
        return _buildSplashScreen();
      case AppScreen.auth:
        return _buildAuthScreen();
      case AppScreen.signup:
        return _buildSignupScreen();
      case AppScreen.login:
        return _buildLoginScreen();
      case AppScreen.mainMenu:
        return _buildMainMenuScreen();
      case AppScreen.category:
        return _buildCategoryScreen();
      case AppScreen.quiz:
        return _buildQuizScreen();
      case AppScreen.shapes:
        return _buildShapesScreen();
      case AppScreen.success:
        return _buildSuccessScreen();
      case AppScreen.wrongAnswer:
        return _buildWrongAnswerScreen();
      case AppScreen.result:
        return _buildResultScreen();
      case AppScreen.settings:
        return _buildSettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _buildCurrentScreen(),
      ),
    );
  }

  // --- WIDGETS FOR EACH SCREEN ---

  Widget _buildSplashScreen() {
    return Container(
      key: const ValueKey('splash'),
      color: const Color(0xFFE0F7FA),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🐰', style: TextStyle(fontSize: 100)),
            SizedBox(height: 20),
            Text(
              "Math Kid's",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Color(0xFF4DD0E1), offset: Offset(2, 2)),
                ],
              ),
            ),
            Text(
              '1234',
              style: TextStyle(fontSize: 24, color: Color(0xFF00ACC1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthScreen() {
    return buildPage(
      key: const ValueKey('auth'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useLogo)
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4DD0E1), width: 6),
                ),
                child: ClipOval(
                  child: Image.asset(
                    logoPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('🐰', style: TextStyle(fontSize: 100));
                    },
                  ),
                ),
              )
            else
              const Text('🐰', style: TextStyle(fontSize: 100)),
            const SizedBox(height: 16),
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Color(0xFF4DD0E1), offset: Offset(2, 2)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            AppButton(
              text: 'สมัครสมาชิก',
              onPressed: () {
                _soundService.playButtonSound();
                _showScreen(AppScreen.signup);
              },
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'เข้าสู่ระบบ',
              onPressed: () {
                _soundService.playButtonSound();
                _showScreen(AppScreen.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupScreen() {
    return buildPage(
      key: const ValueKey('signup'),
      showBackButton: true,
      onBack: () => _showScreen(AppScreen.auth),
      child: ListView(
        padding: const EdgeInsets.all(32.0),
        children: [
          const SizedBox(height: 60),
          const Text(
            'สร้างบัญชีใหม่',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Color(0xFF4DD0E1), offset: Offset(2, 2))],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const AppTextField(hint: 'ชื่อผู้ใช้'),
          const SizedBox(height: 16),
          const AppTextField(
            hint: 'เบอร์โทรศัพท์',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          const AppTextField(hint: 'รหัสผ่าน', obscureText: true),
          const SizedBox(height: 16),
          const AppTextField(hint: 'ยืนยันรหัสผ่าน', obscureText: true),
          const SizedBox(height: 32),
          AppButton(
            text: 'สมัครเลย',
            onPressed: () {
              _soundService.playButtonSound();
              _showScreen(AppScreen.mainMenu);
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginScreen() {
    return buildPage(
      key: const ValueKey('login'),
      showBackButton: true,
      onBack: () => _showScreen(AppScreen.auth),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'เข้าสู่ระบบ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Color(0xFF4DD0E1), offset: Offset(2, 2)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const AppTextField(hint: 'ชื่อผู้ใช้'),
            const SizedBox(height: 16),
            const AppTextField(hint: 'รหัสผ่าน', obscureText: true),
            const SizedBox(height: 32),
            AppButton(
              text: 'ล็อกอิน',
              onPressed: () {
                _soundService.playButtonSound();
                _showScreen(AppScreen.mainMenu);
              },
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuScreen() {
    return buildPage(
      key: const ValueKey('mainMenu'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'เมนูหลัก',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Color(0xFF4DD0E1), offset: Offset(24, 2)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // ปุ่มเรียนรู้
            GestureDetector(
              onTap: () {
                _soundService.playButtonSound();
                _showScreen(AppScreen.category);
              },
              child: Container(
                width: 200,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // สีฟ้าอ่อน
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4DD0E1), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF4DD0E1),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/IMAGE/LOGO.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.psychology,
                              size: 80,
                              color: Color(0xFF4DD0E1),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'เรียนรู้',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4DD0E1),
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // ปุ่มการตั้งค่า
            GestureDetector(
              onTap: () {
                _soundService.playButtonSound();
                _showScreen(AppScreen.settings);
              },
              child: Container(
                width: 200,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // สีฟ้าอ่อน
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4DD0E1), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF4DD0E1),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.settings,
                        size: 80,
                        color: Color(0xFF4DD0E1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'การตั้งค่า',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4DD0E1),
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'ออกจากระบบ',
              onPressed: () {
                _soundService.playButtonSound();
                _showScreen(AppScreen.auth);
              },
              color: Colors.red.shade400,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScreen() {
    return Container(
      key: const ValueKey('category'),
      decoration: const BoxDecoration(
        color: Color(0xFFE0F7FA), // พื้นหลังสีฟ้าอ่อน
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF4DD0E1),
                      size: 28,
                    ),
                    onPressed: () {
                      _soundService.playButtonSound();
                      _showScreen(AppScreen.mainMenu);
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'หมวดหมู่',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4DD0E1),
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Color(0xFF4DD0E1),
                      size: 28,
                    ),
                    onPressed: () {
                      _soundService.playButtonSound();
                      _showScreen(AppScreen.settings);
                    },
                  ),
                ],
              ),
            ),
            // Main Content with Clouds
            Expanded(
              child: Stack(
                children: [
                  // Background stars
                  ...List.generate(
                    20,
                    (index) => Positioned(
                      left: (index * 47.0) % MediaQuery.of(context).size.width,
                      top: (index * 73.0) % MediaQuery.of(context).size.height,
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                  // Cloud buttons
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top row - Addition and Subtraction
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCloudButton(
                              'การบวก',
                              _buildAdditionIllustration(),
                              () {
                                _soundService.playButtonSound();
                                _startQuiz('addition');
                              },
                              const Color(0xFF4DD0E1),
                            ),
                            _buildCloudButton(
                              'การลบ',
                              _buildSubtractionIllustration(),
                              () {
                                _soundService.playButtonSound();
                                _startQuiz('subtraction');
                              },
                              const Color(0xFF4DD0E1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Middle row - Multiplication and Division
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCloudButton(
                              'การคูณ',
                              _buildMultiplicationIllustration(),
                              () {
                                _soundService.playButtonSound();
                                _startQuiz('multiplication');
                              },
                              const Color(0xFF4DD0E1),
                            ),
                            _buildCloudButton(
                              'การหาร',
                              _buildDivisionIllustration(),
                              () {
                                _soundService.playButtonSound();
                                _startQuiz('division');
                              },
                              const Color(0xFF4DD0E1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Bottom row - Geometric Shapes
                        Center(
                          child: _buildCloudButton(
                            'รูปเรขาคณิต',
                            _buildGeometricIllustration(),
                            () {
                              _soundService.playButtonSound();
                              _showScreen(AppScreen.shapes);
                            },
                            const Color(0xFF4DD0E1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudButton(
    String title,
    Widget illustration,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD), // สีฟ้าอ่อนเหมือนในภาพ
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white,
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Bow at the top - โบว์สีน้ำเงินเข้ม
            Positioned(
              top: 5,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 24,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E), // สีน้ำเงินเข้ม
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: illustration),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionIllustration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // กระต่ายสีขาวตัวแรก
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🐰', style: TextStyle(fontSize: 20)),
          ),
        ),
        // เครื่องหมายบวกสีฟ้า
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF4DD0E1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '+',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // กระต่ายสีขาวตัวที่สอง
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🐰', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtractionIllustration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // กระต่ายสีขาวตัวแรก
        Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🐰', style: TextStyle(fontSize: 16)),
          ),
        ),
        // เครื่องหมายลบสีชมพู
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.pink,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '-',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // กระต่ายสีขาวตัวที่สอง (เล็กกว่า)
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🐰', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiplicationIllustration() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // แถวบน - กระต่าย 2 ตัว
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 16)),
              ),
            ),
            Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
        // เครื่องหมายคูณสีแดง
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '×',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // แถวล่าง - กระต่าย 2 ตัว
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 16)),
              ),
            ),
            Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivisionIllustration() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // แถวบน - กระต่าย 3 ตัว
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 12)),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 12)),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        // เครื่องหมายหารสีม่วง
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '÷',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // แถวล่าง - กระต่าย 3 ตัว
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 12)),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 12)),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐰', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeometricIllustration() {
    return SizedBox(
      width: 120,
      height: 60,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          // วงกลมสีเขียว
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👀', style: TextStyle(fontSize: 16)),
            ),
          ),
          // สามเหลี่ยมสีเหลือง
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.rectangle,
            ),
            child: const Center(
              child: Text('🔺', style: TextStyle(fontSize: 16)),
            ),
          ),
          // สี่เหลี่ยมสีส้ม
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.rectangle,
            ),
            child: const Center(
              child: Text('⬜', style: TextStyle(fontSize: 16)),
            ),
          ),
          // วงกลมสีม่วง
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👀', style: TextStyle(fontSize: 16)),
            ),
          ),
          // วงกลมสีชมพู
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👀', style: TextStyle(fontSize: 16)),
            ),
          ),
          // วงกลมสีน้ำเงินเล็ก
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('⭕', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen() {
    if (_currentQuestion.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final quizInfo = quizData[_currentQuizType]!;

    return buildPage(
      key: ValueKey('quiz_$_currentQuizType'),
      title: quizInfo['title'] as String,
      showBackButton: true,
      onBack: () => _showScreen(AppScreen.category),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.pink.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⭐️ $_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ข้อที่ ${_questionCount + 1} / $_totalQuestions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    '${_currentQuestion['q']} = ?',
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // ปุ่มอ่านโจทย์ซ้ำ
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      _isTtsOn ? Icons.volume_up : Icons.volume_off,
                      size: 30,
                      color: const Color(0xFF4DD0E1),
                    ),
                    onPressed: () {
                      _soundService.playButtonSound();
                      if (_isTtsOn) {
                        final questionText = _currentQuestion['q'] as String;
                        _soundService.speakQuestion('$questionText = ?');
                      }
                    },
                    tooltip: 'อ่านโจทย์ซ้ำ',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: (_currentQuestion['options'] as List<int>).map((
                  option,
                ) {
                  return AppButton(
                    text: '$option',
                    onPressed: () {
                      _soundService.playButtonSound();
                      _checkAnswer(option);
                    },
                    textSize: 40,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapesScreen() {
    return buildPage(
      key: const ValueKey('shapes'),
      title: 'รูปเรขาคณิต',
      showBackButton: true,
      onBack: () => _showScreen(AppScreen.category),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ShapeCard(
            color: Colors.purple.shade300,
            icon: Icons.circle, // สัญลักษณ์วงกลม
            label: 'วงกลม',
            onTap: () {
              _soundService.playButtonSound();
              _soundService.speakQuestion('วงกลม');
            },
          ),
          ShapeCard(
            color: Colors.pink.shade300,
            icon:
                Icons.square, // สัญลักษณ์สี่เหลี่ยม (หรือใช้ Icons.crop_square)
            label: 'สี่เหลี่ยม',
            onTap: () {
              _soundService.playButtonSound();
              _soundService.speakQuestion('สี่เหลี่ยม');
            },
          ),
          ShapeCard(
            color: Colors.indigo.shade300,
            icon: Icons.change_history, // สัญลักษณ์สามเหลี่ยม
            label: 'สามเหลี่ยม',
            onTap: () {
              _soundService.playButtonSound();
              _soundService.speakQuestion('สามเหลี่ยม');
            },
          ),
          ShapeCard(
            color: Colors.teal.shade300,
            icon: Icons.hexagon, // สัญลักษณ์หกเหลี่ยม
            label: 'หกเหลี่ยม',
            onTap: () {
              _soundService.playButtonSound();
              _soundService.speakQuestion('หกเหลี่ยม');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return buildPage(
      key: const ValueKey('success'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 20),
          const Text(
            'You did it!',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Color(0xFF4DD0E1), offset: Offset(2, 2))],
            ),
          ),
          const Text(
            'เก่งมากเลย!',
            style: TextStyle(fontSize: 24, color: Color(0xFF00ACC1)),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NavIconButton(
                icon: Icons.home,
                onPressed: () {
                  _soundService.playButtonSound();
                  _showScreen(AppScreen.category);
                },
              ),
              const SizedBox(width: 24),
              NavIconButton(
                icon: Icons.refresh,
                onPressed: () {
                  _soundService.playButtonSound();
                  _startQuiz(_currentQuizType);
                },
              ),
              const SizedBox(width: 24),
              NavIconButton(
                icon: Icons.arrow_forward,
                onPressed: () {
                  _soundService.playButtonSound();
                  _nextQuestion();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWrongAnswerScreen() {
    return buildPage(
      key: const ValueKey('wrongAnswer'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😢', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 20),
          const Text(
            'ไม่ถูกต้อง',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Color(0xFF4DD0E1), offset: Offset(2, 2))],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'คำตอบที่คุณเลือก: $_wrongAnswer',
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF00ACC1),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'คำตอบที่ถูกต้อง: ${_currentQuestion['a']}',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ลองใหม่อีกครั้งนะ!',
            style: TextStyle(fontSize: 20, color: Color(0xFF00ACC1)),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NavIconButton(
                icon: Icons.home,
                onPressed: () {
                  _soundService.playButtonSound();
                  _showScreen(AppScreen.category);
                },
              ),
              const SizedBox(width: 24),
              NavIconButton(
                icon: Icons.refresh,
                onPressed: () {
                  _soundService.playButtonSound();
                  _showScreen(AppScreen.quiz);
                },
              ),
              const SizedBox(width: 24),
              NavIconButton(
                icon: Icons.arrow_forward,
                onPressed: () {
                  _soundService.playButtonSound();
                  _nextQuestion();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final quizInfo = quizData[_currentQuizType]!;
    final quizTitle = quizInfo['title'] as String;
    final correctAnswers = _score;
    final wrongAnswers = _totalQuestions - _score;
    final percentage = (_score / _totalQuestions * 100).round();

    // กำหนดข้อความและไอคอนตามคะแนน
    String message;
    String emoji;
    Color messageColor;

    if (percentage >= 80) {
      message = 'ยอดเยี่ยมมาก!';
      emoji = '🎉';
      messageColor = Colors.green;
    } else if (percentage >= 60) {
      message = 'ดีมาก!';
      emoji = '👏';
      messageColor = Colors.blue;
    } else if (percentage >= 40) {
      message = 'ดีแล้ว!';
      emoji = '👍';
      messageColor = Colors.orange;
    } else {
      message = 'พยายามอีกนิดนะ!';
      emoji = '💪';
      messageColor = Colors.red;
    }

    return buildPage(
      key: const ValueKey('result'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(emoji, style: const TextStyle(fontSize: 100)),
              const SizedBox(height: 20),
              Text(
                'สรุปผลคะแนน',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Color(0xFF4DD0E1), offset: Offset(2, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                quizTitle,
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFF00ACC1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // แสดงคะแนน
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$_score / $_totalQuestions',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: messageColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: messageColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // แสดงสถิติ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    'ตอบถูก',
                    '$correctAnswers',
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildStatCard(
                    'ตอบผิด',
                    '$wrongAnswers',
                    Colors.red,
                    Icons.cancel,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // ปุ่มกลับและเล่นใหม่
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'กลับหน้าหมวดหมู่',
                      onPressed: () {
                        _soundService.playButtonSound();
                        _showScreen(AppScreen.category);
                      },
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: 'เล่นใหม่',
                      onPressed: () {
                        _soundService.playButtonSound();
                        _startQuiz(_currentQuizType);
                      },
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 16, color: color)),
        ],
      ),
    );
  }

  Widget _buildSettingsScreen() {
    return buildPage(
      key: const ValueKey('settings'),
      title: 'การตั้งค่า',
      showBackButton: true,
      onBack: () => _showScreen(AppScreen.mainMenu),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SettingsTile(
              icon: _isSoundOn ? Icons.volume_up : Icons.volume_off,
              label: 'เสียงประกอบ',
              value: _isSoundOn,
              onChanged: (val) {
                setState(() => _isSoundOn = val);
                _soundService.setSoundEnabled(val);
              },
            ),
            const SizedBox(height: 16),
            SettingsTile(
              icon: _isMusicOn ? Icons.music_note : Icons.music_off,
              label: 'เพลง',
              value: _isMusicOn,
              onChanged: (val) {
                setState(() => _isMusicOn = val);
                // setMusicEnabled จะจัดการเล่นหรือหยุดเพลงอัตโนมัติ
                _soundService.setMusicEnabled(val);
              },
            ),
            const SizedBox(height: 16),
            SettingsTile(
              icon: _isTtsOn ? Icons.record_voice_over : Icons.voice_over_off,
              label: 'เสียงอ่านโจทย์',
              value: _isTtsOn,
              onChanged: (val) {
                setState(() => _isTtsOn = val);
                _soundService.setTtsEnabled(val);
                if (!val) {
                  _soundService.stopSpeaking();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM WIDGETS ---

// A helper for building standard page layouts
Widget buildPage({
  required Widget child,
  Key? key,
  String? title,
  bool showBackButton = false,
  VoidCallback? onBack,
  List<Widget>? actions,
}) {
  return Container(
    key: key,
    decoration: const BoxDecoration(
      color: Color(0xFFE0F7FA),
      // Background pattern removed - file doesn't exist
    ),
    child: SafeArea(
      child: Column(
        children: [
          if (title != null || showBackButton)
            AppBar(
              title: Text(
                title ?? '',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Color(0xFF4DD0E1), offset: Offset(2, 2)),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // ไม่ต้องเล่นเสียงเมื่อกด back button เพราะจะรบกวนมาก
                        if (onBack != null) onBack();
                      },
                    )
                  : null,
              centerTitle: true,
              actions: actions,
            ),
          Expanded(child: Center(child: child)),
        ],
      ),
    ),
  );
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color? color;
  final double textSize;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.color,
    this.textSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              color ?? (isPrimary ? const Color(0xFFFFC107) : Colors.white),
          foregroundColor: isPrimary ? Colors.white : Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color:
                  color ?? (isPrimary ? Colors.white : const Color(0xFFFCE47C)),
              width: 4,
            ),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;

  const AppTextField({
    super.key,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color(0xFF4DD0E1),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color(0xFF4DD0E1),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isWide;

  const CategoryButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: GridTile(
        footer: isWide ? const SizedBox.shrink() : null,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 4),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 50, color: Colors.white),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShapeCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ShapeCard({
    super.key,
    required this.color,
    required this.label,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 3. ครอบด้วย GestureDetector เพื่อดักจับการกด
      onTap: onTap,
      child: Card(
        color: color,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2), // พื้นหลังจางๆ
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, // แสดงไอคอนที่รับมา
                  size: 60, // ขนาดไอคอน
                  color: Colors.white, // สีไอคอน
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const NavIconButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      child: Icon(icon, size: 40, color: Colors.cyan.shade700),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.cyan.shade800),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064), // cyan[900]
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Colors.green.shade300,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

// --- DATA ---
const quizData = {
  'addition': {
    'title': 'การบวกเลข',
    'questions': [
      {'q': '5 + 3', 'a': 8},
      {'q': '7 + 2', 'a': 9},
      {'q': '10 + 4', 'a': 14},
      {'q': '6 + 6', 'a': 12},
      {'q': '8 + 5', 'a': 13},
    ],
  },
  'subtraction': {
    'title': 'การลบเลข',
    'questions': [
      {'q': '10 - 6', 'a': 4},
      {'q': '8 - 3', 'a': 5},
      {'q': '12 - 5', 'a': 7},
      {'q': '9 - 9', 'a': 0},
      {'q': '15 - 7', 'a': 8},
    ],
  },
  'multiplication': {
    'title': 'การคูณเลข',
    'questions': [
      {'q': '7 × 5', 'a': 35},
      {'q': '3 × 4', 'a': 12},
      {'q': '6 × 2', 'a': 12},
      {'q': '8 × 3', 'a': 24},
      {'q': '5 × 5', 'a': 25},
    ],
  },
  'division': {
    'title': 'การหารเลข',
    'questions': [
      {'q': '10 ÷ 2', 'a': 5},
      {'q': '12 ÷ 4', 'a': 3},
      {'q': '9 ÷ 3', 'a': 3},
      {'q': '20 ÷ 5', 'a': 4},
      {'q': '14 ÷ 2', 'a': 7},
    ],
  },
};
