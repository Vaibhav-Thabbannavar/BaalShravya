class ApiEndpoints {
  // base URL — switch between dev and prod
  static const String baseUrl =
      'https://baalshravya-api-production.up.railway.app/api';
      // for local testing use:
      // 'http://10.0.2.2:5000/api'  ← Android emulator
      // 'http://localhost:5000/api'  ← iOS simulator

  // auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // geography
  static const String districts = '/districts';
  static String healthCenters(String districtId) =>
      '/districts/$districtId/health-centers';

  // infants
  static const String infants = '/infants';
  static const String myInfants = '/infants/my-infants';
  static const String myCenter = '/infants/my-center';
  static String infantById(String id) => '/infants/$id';
  static String infantsByParent(String parentId) =>
      '/infants/parent/$parentId';

  // sessions
  static const String sessions = '/sessions';
  static const String mySessions = '/sessions/my-sessions';
  static String sessionById(String id) => '/sessions/$id';
  static String completeSession(String id) => '/sessions/$id/complete';
  static String sessionsByInfant(String infantId) =>
      '/sessions/infant/$infantId';

  // boa
  static const String boa = '/boa';
  static String boaBySession(String sessionId) => '/boa/session/$sessionId';

  // questionnaire
  static const String questions = '/questionnaire/questions';
  static const String submitQuestionnaire = '/questionnaire/submit';
  static String questionnaireBySession(String sessionId) =>
      '/questionnaire/session/$sessionId';

  // dashboard
  static const String adminDashboard = '/dashboard/admin';
  static const String anmDashboard = '/dashboard/anm';

  // awareness
  static const String awareness = '/awareness';
  static String awarenessById(String id) => '/awareness/$id';
}