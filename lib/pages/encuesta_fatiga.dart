import 'package:flutter/material.dart';

class EncuestaFatiga extends StatefulWidget {
  const EncuestaFatiga({super.key});

  @override
  State<EncuestaFatiga> createState() => _EncuestaFatigaState();
}

class _EncuestaFatigaState extends State<EncuestaFatiga> {
  bool showSurvey = true;

  // Listas para manejar la lógica dinámica
  late List<PreguntaConfig> preguntasActivas;
  late List<bool?> userAnswers;

  @override
  void initState() {
    super.initState();
    _inicializarPreguntas();
  }

  void _inicializarPreguntas() {
    // true = SI es lo seguro (Ideal)
    // false = NO es lo seguro (Ideal)
    List<PreguntaConfig> bancoDePreguntas = [
      PreguntaConfig(
        '¿Has dormido mas de 7 horas en las últimas 24 horas?',
        true,
      ), // Ideal: SI
      PreguntaConfig(
        '¿Me encuentro físicamente apto para conducir?',
        true,
      ), // Ideal: SI
      PreguntaConfig(
        '¿Tienes dificultad para concentrarte?',
        false,
      ), // Ideal: NO
      PreguntaConfig(
        '¿He conducido mas de 5 horas sin descansar?',
        false,
      ), // Ideal: NO
    ];

    //Barajar preguntas
    bancoDePreguntas.shuffle();

    //Asignar al estado
    preguntasActivas = bancoDePreguntas;

    //Inicializar respuestas vacías
    userAnswers = List.filled(preguntasActivas.length, null);
  }

  bool get allQuestionsAnswered => userAnswers.every((a) => a != null);

  // Lógica al enviar la encuesta + validaciones
  void handleSubmit() {
    //Validar que respondió todo
    if (!allQuestionsAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor responde todas las preguntas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Calcular Puntaje (Respuestas Seguras)
    int puntajeCorrecto = 0;

    for (int i = 0; i < preguntasActivas.length; i++) {
      // Comparamos respuesta usuario vs respuesta ideal
      if (userAnswers[i] == preguntasActivas[i].respuestaIdeal) {
        puntajeCorrecto++;
      }
    }

    //Lógica de Aprobación
    // Si tiene 2 o más respuestas SEGURAS -> Aprueba
    if (puntajeCorrecto >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Encuesta completada correctamente. Estado seguro.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    } else {
      // Si tiene menos de 2 seguras -> Alerta
      setState(() => showSurvey = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ALERTA: Solo tuviste $puntajeCorrecto respuestas seguras. NO CONDUCIR.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Fatiga'),
        backgroundColor: const Color(0xFFF35F34),
        foregroundColor: Colors.white,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: showSurvey ? _buildSurvey() : _buildAlert(),
      ),
    );
  }

  // --- WIDGET ENCUESTA ---
  Widget _buildSurvey() {
    return Container(
      key: const ValueKey('survey'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              // Generación dinámica de tarjetas
              ...List.generate(
                preguntasActivas.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildQuestionCard(i),
                ),
              ),
              const SizedBox(height: 16),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET ENCABEZADO ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.battery_alert_outlined,
            size: 48,
            color: Color(0xFFF35F34),
          ),
          const SizedBox(height: 16),
          const Text(
            'Encuesta de Fatiga',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF35F34),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Responde estas preguntas para evaluar tu nivel de fatiga.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PREGUNTA ---
  Widget _buildQuestionCard(int index) {
    final pregunta = preguntasActivas[index];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: userAnswers[index] != null
              ? const Color(0xFFF35F34).withOpacity(0.3)
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF35F34).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF35F34),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // Usamos el texto del objeto pregunta
                child: Text(
                  pregunta.texto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnswerButton(
                  'Sí',
                  Icons.check_circle_outline,
                  userAnswers[index] == true,
                  () {
                    setState(() => userAnswers[index] = true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnswerButton(
                  'No',
                  Icons.cancel_outlined,
                  userAnswers[index] == false,
                  () {
                    setState(() => userAnswers[index] = false);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET BOTONES Y ALERTA ---
  Widget _buildAnswerButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF35F34) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF35F34) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BOTÓN ENVIAR ---
  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: allQuestionsAnswered
              ? [
                  const Color(0xFFF35F34),
                  const Color.fromARGB(255, 185, 120, 104),
                ]
              : [Colors.grey.shade400, Colors.grey.shade500],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: allQuestionsAnswered
            ? [
                BoxShadow(
                  color: const Color(0xFFF35F34).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Enviar Encuesta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET ALERTA ---
  Widget _buildAlert() {
    // Calculamos cuántas incorrectas (peligrosas) hubo para mostrar en la alerta
    int segurasCount = 0;
    if (userAnswers.isNotEmpty) {
      for (int i = 0; i < preguntasActivas.length; i++) {
        if (userAnswers[i] == preguntasActivas[i].respuestaIdeal) {
          segurasCount++;
        }
      }
    }

    return Container(
      key: const ValueKey('alert'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 64,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¡Alerta de Fatiga! ⚠️',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tus respuestas indican riesgo. Solo tuviste $segurasCount respuestas seguras. Por tu seguridad, no puedes conducir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF35F34),
                        Color.fromARGB(255, 185, 120, 104),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF35F34).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Volver',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PreguntaConfig {
  final String texto;
  final bool respuestaIdeal;

  PreguntaConfig(this.texto, this.respuestaIdeal);
}
