import 'package:flutter/material.dart';

class EncuestaFatiga extends StatefulWidget {
  const EncuestaFatiga({super.key});

  @override
  State<EncuestaFatiga> createState() => _EncuestaFatigaState();
}

class _EncuestaFatigaState extends State<EncuestaFatiga> {
  bool showSurvey = true;
  final List<bool?> answers = List.filled(7, null);

  final List<String> questions = [
    '¿Has dormido mas de 7 horas en las últimas 24 horas?', //SI
    '¿Me encuentro físicamente apto para conducir?', //SI
    '¿Tienes dificultad para concentrarte?', //NO
    '¿He conducido mas de 5 horas sin descansar agregar?', //NO
  ];

  bool get allQuestionsAnswered => answers.every((a) => a != null);

  void handleSubmit() {
    if (!allQuestionsAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor responde todas las preguntas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    int yesCount = answers.where((a) => a == true).length;

    if (yesCount >= 4) {
      setState(() => showSurvey = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ALERTA: $yesCount respuestas "Sí". NO CONDUCIR.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Encuesta completada correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
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

  //Creacion de widget de encuesta
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
              ...List.generate(
                questions.length,
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
            'Responde estas 7 preguntas para evaluar tu nivel de fatiga.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: answers[index] != null
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
                child: Text(
                  questions[index],
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
                  answers[index] == true,
                  () {
                    setState(() => answers[index] = true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnswerButton(
                  'No',
                  Icons.cancel_outlined,
                  answers[index] == false,
                  () {
                    setState(() => answers[index] = false);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildAlert() {
    int yesCount = answers.where((a) => a == true).length;

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
                        'Se detectaron $yesCount respuestas "Sí". Por tu seguridad, no puedes conducir y se recomienda descanso inmediato.',
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
                    onPressed: () => Navigator.pop(context),
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
