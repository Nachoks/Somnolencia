import 'package:flutter/material.dart';

class EncuestaSomnolencia extends StatefulWidget {
  const EncuestaSomnolencia({super.key});

  @override
  State<EncuestaSomnolencia> createState() => _EncuestaSomnolenciaState();
}

class _EncuestaSomnolenciaState extends State<EncuestaSomnolencia> {
  bool showSurvey = true;
  final List<bool?> answers = List.filled(6, null);

  final List<String> questions = [
    '¿Sientes sueño en este momento?', //NO
    '¿Te sientes suficientemente alerta para conducir?', //SI
    '¿Sientes pesadez en los ojos?', //NO
    '¿Tus movimientos son más lentos o torpes de lo normal?', //NO
  ];

  bool get allQuestionsAnswered => answers.every((a) => a != null);
  // Manejar el envío de la encuesta (validación >4 y alerta)
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
          content: Text(
            'Alerta de Somnolencia: Se detectaron $yesCount respuestas "Sí". Se recomienda descanso.',
          ),
          backgroundColor: Colors.red,
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
        title: const Text('Test de Somnolencia'),
        backgroundColor: const Color(0xFFF35F34),
        foregroundColor: Colors.white,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: showSurvey ? _buildSurvey() : _buildAlert(),
      ),
    );
  }

  // --- WIDGETS DESGLOSADOS ---
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

  // --- WIDGETS AUXILIARES ---
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
          const Icon(Icons.bed_outlined, size: 48, color: Color(0xFFF35F34)),
          const SizedBox(height: 16),
          const Text(
            'Encuesta de Somnolencia',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF35F34),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Por favor responde las siguientes preguntas sobre tu estado de alerta',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  //Create question card widget
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

  // Crear answer button widget
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

  // Crear submit button widget
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

  // Alerta widget por alta somnolencia
  Widget _buildAlert() {
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
                  padding: const EdgeInsets.all(20),
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
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Alerta de Somnolencia!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Los resultados indican un nivel de somnolencia elevado. Por favor, no continúe con sus tareas y busque descanso.',
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
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade600, Colors.grey.shade400],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade600.withOpacity(0.4),
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
                          'Volver al Inicio',
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
