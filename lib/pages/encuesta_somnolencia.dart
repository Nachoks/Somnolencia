import 'package:flutter/material.dart';

class EncuestaSomnolencia extends StatefulWidget {
  const EncuestaSomnolencia({super.key});

  @override
  State<EncuestaSomnolencia> createState() => _EncuestaSomnolenciaState();
}

class _EncuestaSomnolenciaState extends State<EncuestaSomnolencia> {
  // Variable para alternar entre la encuesta y la alerta roja
  bool showSurvey = true;

  // Listas para manejar la lógica dinámica
  late List<PreguntaConfig> preguntasActivas;
  late List<bool?> userAnswers;

  @override
  void initState() {
    super.initState();
    _inicializarPreguntas();
  }

  // Inicializa las preguntas y las respuestas del usuario
  void _inicializarPreguntas() {
    //Banco de Preguntas con su respuesta ideal
    // true = SÍ es lo seguro, false = NO es lo seguro
    List<PreguntaConfig> bancoDePreguntas = [
      PreguntaConfig('¿Sientes sueño en este momento?', false), // Ideal: NO
      PreguntaConfig(
        '¿Te sientes suficientemente alerta para conducir?',
        true,
      ), // Ideal: SI
      PreguntaConfig('¿Sientes pesadez en los ojos?', false), // Ideal: NO
      PreguntaConfig(
        '¿Tus movimientos son más lentos o torpes de lo normal?',
        false,
      ), // Ideal: NO
    ];

    //Barajamos las preguntas para que salgan en orden aleatorio
    bancoDePreguntas.shuffle();

    //Asignamos a la variable del estado
    preguntasActivas = bancoDePreguntas;

    //Preparamos la lista de respuestas del usuario (inicialmente nulas)
    userAnswers = List.filled(preguntasActivas.length, null);
  }

  // Verifica si todas las preguntas tienen respuesta (true o false)
  bool get allQuestionsAnswered => userAnswers.every((a) => a != null);

  // Lógica al enviar la encuesta + validaciones
  void handleSubmit() {
    // Validación 1: ¿Respondió todo?
    if (!allQuestionsAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor responde todas las preguntas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validación 2: Calcular Puntaje
    int puntajeCorrecto = 0;

    for (int i = 0; i < preguntasActivas.length; i++) {
      // Comparamos la respuesta del usuario con la respuesta ideal de ESA pregunta
      if (userAnswers[i] == preguntasActivas[i].respuestaIdeal) {
        puntajeCorrecto++;
      }
    }

    // Validación 3: Decisión final
    // REGLA: Si tiene 2 o más respuestas seguras, aprueba.
    if (puntajeCorrecto >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Test Aprobado: Tienes $puntajeCorrecto respuestas seguras.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      // Cierra la pantalla y devuelve "true" (aprobado)
      Navigator.pop(context, true);
    } else {
      // Reprueba -> Muestra pantalla roja
      setState(() => showSurvey = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alerta: Solo tuviste $puntajeCorrecto respuestas seguras. Descansa.',
          ),
          backgroundColor: Colors.red,
        ),
      );
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

  // --- PANTALLA DE ENCUESTA ---
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

              // Generamos las tarjetas dinámicamente según la lista mezclada
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

  // --- TARJETA DE PREGUNTA ---
  Widget _buildQuestionCard(int index) {
    final pregunta = preguntasActivas[index]; // Obtenemos el objeto actual

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
                // Mostramos el texto de la pregunta actual
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

  // --- BOTÓN DE RESPUESTA INDIVIDUAL ---
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

  // --- BOTÓN ENVIAR ---
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

  // --- PANTALLA DE ALERTA ---
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

  // --- HEADER (CABECERA) ---
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
}

// Clase para definir la configuración de cada pregunta
class PreguntaConfig {
  final String texto;
  // Esta variable define qué debe responder el usuario para que sea SEGURO.
  // Ej: "¿Tienes sueño?" -> respuestaIdeal: false (NO)
  final bool respuestaIdeal;

  PreguntaConfig(this.texto, this.respuestaIdeal);
}
