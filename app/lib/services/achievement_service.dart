import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String icon;
  final String titleEn;
  final String titlePt;
  final String titleAr;
  final String descEn;
  final String descPt;
  final String descAr;
  final bool Function(AchievementProgress) check;

  Achievement({
    required this.id,
    required this.icon,
    required this.titleEn,
    required this.titlePt,
    required this.titleAr,
    required this.descEn,
    required this.descPt,
    required this.descAr,
    required this.check,
  });
}

class AchievementProgress {
  final int lessonsCompleted;
  final int exercisesCompleted;
  final int favorites;
  final int streak;
  final int flashcardsReviewed;
  final int quizzesTaken;
  final int verbsExplored;
  final int daysStudied;
  final int speakingDone;
  final bool backupDone;

  AchievementProgress({
    required this.lessonsCompleted,
    required this.exercisesCompleted,
    required this.favorites,
    required this.streak,
    required this.flashcardsReviewed,
    required this.quizzesTaken,
    required this.verbsExplored,
    required this.daysStudied,
    required this.speakingDone,
    required this.backupDone,
  });
}

class AchievementService {
  static final AchievementService instance = AchievementService._();
  AchievementService._();

  static const _unlockedKey = 'achievements_unlocked';

  final List<Achievement> all = [
    Achievement(
      id: 'first_lesson',
      icon: '📖',
      titleEn: 'First Steps',
      titlePt: 'Primeiros Passos',
      titleAr: 'خطوات أولى',
      descEn: 'Complete your first lesson',
      descPt: 'Complete sua primeira lição',
      descAr: 'أكمل درسك الأول',
      check: (p) => p.lessonsCompleted >= 1,
    ),
    Achievement(
      id: 'five_lessons',
      icon: '📚',
      titleEn: 'Student',
      titlePt: 'Estudante',
      titleAr: 'طالب',
      descEn: 'Complete 5 lessons',
      descPt: 'Complete 5 lições',
      descAr: 'أكمل 5 دروس',
      check: (p) => p.lessonsCompleted >= 5,
    ),
    Achievement(
      id: 'twenty_lessons',
      icon: '🎓',
      titleEn: 'Scholar',
      titlePt: 'Estudioso',
      titleAr: 'طالب علم',
      descEn: 'Complete 20 lessons',
      descPt: 'Complete 20 lições',
      descAr: 'أكمل 20 درساً',
      check: (p) => p.lessonsCompleted >= 20,
    ),
    Achievement(
      id: 'fifty_lessons',
      icon: '🏅',
      titleEn: 'Master',
      titlePt: 'Mestre',
      titleAr: 'خبير',
      descEn: 'Complete 50 lessons',
      descPt: 'Complete 50 lições',
      descAr: 'أكمل 50 درساً',
      check: (p) => p.lessonsCompleted >= 50,
    ),
    Achievement(
      id: 'all_lessons',
      icon: '🏆',
      titleEn: 'Graduate',
      titlePt: 'Formado',
      titleAr: 'خريج',
      descEn: 'Complete all 72 lessons',
      descPt: 'Complete todas as 72 lições',
      descAr: 'أكمل جميع الدروس الـ 72',
      check: (p) => p.lessonsCompleted >= 72,
    ),
    Achievement(
      id: 'first_exercise',
      icon: '✏️',
      titleEn: 'Getting Started',
      titlePt: 'Começando',
      titleAr: 'بداية',
      descEn: 'Complete 10 exercises',
      descPt: 'Complete 10 exercícios',
      descAr: 'أكمل 10 تمارين',
      check: (p) => p.exercisesCompleted >= 10,
    ),
    Achievement(
      id: 'hundred_exercises',
      icon: '💪',
      titleEn: 'Practice Makes Perfect',
      titlePt: 'Prática Leva à Perfeição',
      titleAr: 'الPractice تؤدي إلى الكمال',
      descEn: 'Complete 100 exercises',
      descPt: 'Complete 100 exercícios',
      descAr: 'أكمل 100 تمرين',
      check: (p) => p.exercisesCompleted >= 100,
    ),
    Achievement(
      id: 'five_hundred_exercises',
      icon: '🔥',
      titleEn: 'Exercise Master',
      titlePt: 'Mestre dos Exercícios',
      titleAr: 'خبير التمارين',
      descEn: 'Complete 500 exercises',
      descPt: 'Complete 500 exercícios',
      descAr: 'أكمل 500 تمرين',
      check: (p) => p.exercisesCompleted >= 500,
    ),
    Achievement(
      id: 'first_favorite',
      icon: '⭐',
      titleEn: 'Collector',
      titlePt: 'Colecionador',
      titleAr: 'جامع',
      descEn: 'Add 5 words to favorites',
      descPt: 'Adicione 5 palavras aos favoritos',
      descAr: 'أضف 5 كلمات للمفضلة',
      check: (p) => p.favorites >= 5,
    ),
    Achievement(
      id: 'streak_3',
      icon: '🔥',
      titleEn: 'On Fire',
      titlePt: 'Em Chamas',
      titleAr: 'في الطريق',
      descEn: 'Study 3 days in a row',
      descPt: 'Estude 3 dias seguidos',
      descAr: 'ادرس 3 أيام متتالية',
      check: (p) => p.streak >= 3,
    ),
    Achievement(
      id: 'streak_7',
      icon: '🔥',
      titleEn: 'Week Warrior',
      titlePt: 'Guerreiro da Semana',
      titleAr: 'محارب الأسبوع',
      descEn: 'Study 7 days in a row',
      descPt: 'Estude 7 dias seguidos',
      descAr: 'ادرس 7 أيام متتالية',
      check: (p) => p.streak >= 7,
    ),
    Achievement(
      id: 'streak_30',
      icon: '💎',
      titleEn: 'Monthly Champion',
      titlePt: 'Campeão Mensal',
      titleAr: 'بطل الشهر',
      descEn: 'Study 30 days in a row',
      descPt: 'Estude 30 dias seguidos',
      descAr: 'ادرس 30 يوماً متتالياً',
      check: (p) => p.streak >= 30,
    ),
    Achievement(
      id: 'quiz_perfect',
      icon: '🎯',
      titleEn: 'Perfect Score',
      titlePt: 'Pontuação Perfeita',
      titleAr: 'نتيجة مثالية',
      descEn: 'Get 10/10 on any quiz',
      descPt: 'Acerte 10/10 em qualquer teste',
      descAr: 'احصل على 10/10 في أي اختبار',
      check: (p) => p.quizzesTaken >= 1,
    ),
    Achievement(
      id: 'flashcards_50',
      icon: '🧠',
      titleEn: 'Brain Trainer',
      titlePt: 'Treinador Cerebral',
      titleAr: 'مدرس الدماغ',
      descEn: 'Review 50 flashcards',
      descPt: 'Revise 50 cartões',
      descAr: 'راجع 50 بطاقة تعليمية',
      check: (p) => p.flashcardsReviewed >= 50,
    ),
    Achievement(
      id: 'flashcards_200',
      icon: '🧩',
      titleEn: 'Memory Master',
      titlePt: 'Mestre da Memória',
      titleAr: 'خبير الذاكرة',
      descEn: 'Review 200 flashcards',
      descPt: 'Revise 200 cartões',
      descAr: 'راجع 200 بطاقة تعليمية',
      check: (p) => p.flashcardsReviewed >= 200,
    ),
    Achievement(
      id: 'explorer',
      icon: '🗺️',
      titleEn: 'Explorer',
      titlePt: 'Explorador',
      titleAr: 'مستكشف',
      descEn: 'Study on 10 different days',
      descPt: 'Estude em 10 dias diferentes',
      descAr: 'ادرس في 10 أيام مختلفة',
      check: (p) => p.daysStudied >= 10,
    ),
    Achievement(
      id: 'dedicated',
      icon: '🌟',
      titleEn: 'Dedicated Learner',
      titlePt: 'Estudante Dedicado',
      titleAr: 'طالب مجتهد',
      descEn: 'Study on 30 different days',
      descPt: 'Estude em 30 dias diferentes',
      descAr: 'ادرس في 30 يوماً مختلفاً',
      check: (p) => p.daysStudied >= 30,
    ),
    Achievement(
      id: 'voice_master',
      icon: '🎤',
      titleEn: 'Voice Master',
      titlePt: 'Mestre da Voz',
      titleAr: 'خبير الصوت',
      descEn: 'Complete 10 speaking exercises',
      descPt: 'Complete 10 exercícios de fala',
      descAr: 'أكمل 10 تمارين تحدث',
      check: (p) => p.speakingDone >= 10,
    ),
    Achievement(
      id: 'backup_champion',
      icon: '🛡️',
      titleEn: 'Data Guardian',
      titlePt: 'Guardião dos Dados',
      titleAr: 'حارس البيانات',
      descEn: 'Export your progress for the first time',
      descPt: 'Exporte seu progresso pela primeira vez',
      descAr: 'صدر تقدمك للمرة الأولى',
      check: (p) => p.backupDone,
    ),
  ];

  Future<Set<String>> _getUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unlockedKey)?.toSet() ?? {};
  }

  Future<void> _saveUnlocked(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unlockedKey, ids.toList());
  }

  Future<List<Achievement>> getUnlocked() async {
    final ids = await _getUnlocked();
    return all.where((a) => ids.contains(a.id)).toList();
  }

  Future<List<Achievement>> checkNew(AchievementProgress progress) async {
    final unlocked = await _getUnlocked();
    final newOnes = <Achievement>[];
    for (final a in all) {
      if (!unlocked.contains(a.id) && a.check(progress)) {
        newOnes.add(a);
        unlocked.add(a.id);
      }
    }
    if (newOnes.isNotEmpty) {
      await _saveUnlocked(unlocked);
    }
    return newOnes;
  }
}
