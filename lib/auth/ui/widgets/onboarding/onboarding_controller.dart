import 'package:flutter/material.dart';

class OnboardingController extends ChangeNotifier {
  int _currentStep = 0;
  String? _selectedLanguage; // Keep for UI logic
  String? _assessmentType;
  String? _name; // Keep for UI, maps to fullName
  String? _email;
  String? _password;
  bool _notificationsEnabled = false;

  // Database fields matching User model schema
  String? _fullName;
  String _profilePictureUrl = 'https://res.cloudinary.com/diugsirlo/image/upload/v1759473921/download_zsyyia.png';
  DateTime? _dateOfBirth;
  String _gender = 'PREFER_NOT_TO_SAY'; // Default gender
  String _nativeLanguage = 'vi'; // Vietnamese as default
  String _targetLanguage = 'en'; // English as default
  String? _proficiencyLevel; // Maps to _experienceLevel from UI
  List<String> _learningGoals = []; // Maps to _selectedGoals from UI
  int _dailyGoalMinutes = 15; // Maps to _dailyGoal from UI
  String _studyReminder = 'DAILY'; // Default daily reminder
  String? _reminderTime; // Format: "HH:mm"
  String _timezone = 'Asia/Ho_Chi_Minh'; // Default timezone
  bool _isEmailVerified = false;
  bool _isActive = true;

  // Getters for UI logic
  int get currentStep => _currentStep;
  String? get selectedLanguage => _selectedLanguage;
  String? get assessmentType => _assessmentType;
  String? get name => _name;
  String? get email => _email;
  String? get password => _password;
  bool get notificationsEnabled => _notificationsEnabled;

  // Database field getters (direct mapping)
  String? get fullName => _fullName ?? _name;
  String get profilePictureUrl => _profilePictureUrl;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get gender => _gender;
  String get nativeLanguage => _nativeLanguage;
  String get targetLanguage => _targetLanguage;
  String? get proficiencyLevel => _proficiencyLevel;
  List<String> get learningGoals => _learningGoals;
  int get dailyGoalMinutes => _dailyGoalMinutes;
  String get studyReminder => _studyReminder;
  String? get reminderTime => _reminderTime;
  String get timezone => _timezone;
  bool get isEmailVerified => _isEmailVerified;
  bool get isActive => _isActive;

  // UI compatibility getters (for backward compatibility)
  String? get experienceLevel => _mapEnumToExperience(_proficiencyLevel);
  List<String> get selectedGoals => _mapEnumToGoals(_learningGoals);
  String? get dailyGoal => _mapMinutesToDailyGoal(_dailyGoalMinutes);

  // Navigation methods
  void nextStep() {
    if (_currentStep < 9) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  // Setters for user data
  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void setExperienceLevel(String level) {
    _proficiencyLevel = _mapExperienceToEnum(level);
    notifyListeners();
  }

  // Direct setter for proficiency level (for when you already have enum value)
  void setExperienceLevelEnum(String enumLevel) {
    _proficiencyLevel = enumLevel;
    notifyListeners();
  }

  void toggleGoal(String goal) {
    String enumGoal = _mapGoalToEnum(goal);
    if (_learningGoals.contains(enumGoal)) {
      _learningGoals.remove(enumGoal);
    } else {
      _learningGoals.add(enumGoal);
    }
    notifyListeners();
  }

  // Direct toggle for enum goal value
  void toggleGoalEnum(String enumGoal) {
    if (_learningGoals.contains(enumGoal)) {
      _learningGoals.remove(enumGoal);
    } else {
      _learningGoals.add(enumGoal);
    }
    notifyListeners();
  }

  void setDailyGoal(String goal) {
    _dailyGoalMinutes = _mapDailyGoalToMinutes(goal);
    notifyListeners();
  }

  // Direct setter for daily goal minutes
  void setDailyGoalMinutes(int minutes) {
    _dailyGoalMinutes = minutes;
    notifyListeners();
  }

  void setAssessmentType(String type) {
    _assessmentType = type;
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    _fullName = name; // Map name to fullName for database
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void setReminderTime(TimeOfDay time) {
    _reminderTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    notifyListeners();
  }

  void setReminderTimeFromString(String timeString) {
    _reminderTime = timeString;
    notifyListeners();
  }

  // Additional setter methods for database fields
  void setProficiencyLevel(String level) {
    _proficiencyLevel = level;
    notifyListeners();
  }

  void setLearningGoals(List<String> goals) {
    _learningGoals = goals;
    notifyListeners();
  }

  void addLearningGoal(String goal) {
    if (!_learningGoals.contains(goal)) {
      _learningGoals.add(goal);
      notifyListeners();
    }
  }

  void removeLearningGoal(String goal) {
    _learningGoals.remove(goal);
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setStudyReminder(String reminder) {
    _studyReminder = reminder;
    notifyListeners();
  }

  void setDateOfBirth(DateTime? date) {
    _dateOfBirth = date;
    notifyListeners();
  }

  void setNativeLanguage(String language) {
    _nativeLanguage = language;
    notifyListeners();
  }

  void setTargetLanguage(String language) {
    _targetLanguage = language;
    notifyListeners();
  }

  // Debug method to check current state
  void printCurrentState() {
    print('OnboardingController State:');
    print('  - proficiencyLevel: $_proficiencyLevel');
    print('  - learningGoals: $_learningGoals');
    print('  - reminderTime: $_reminderTime');
    print('  - dailyGoalMinutes: $_dailyGoalMinutes');
    print('  - gender: $_gender');
    print('  - studyReminder: $_studyReminder');
  }

  // Validation
  bool canProceedFromStep(int step) {
    switch (step) {
      case 0: // Language selection
        return _selectedLanguage != null;
      case 1: // Experience level
        return _proficiencyLevel != null;
      case 2: // Learning goals
        return _learningGoals.isNotEmpty;
      case 3: // Daily goal
        return _dailyGoalMinutes > 0;
      case 4: // Learning benefits
        return true; // Always allow to proceed from benefits screen
      case 5: // Assessment
        return true; // Assessment screen handles its own navigation
      case 6: // Name
        return _name != null && _name!.isNotEmpty;
      case 7: // Email
        return _email != null && _email!.isNotEmpty && _isValidEmail(_email!);
      case 8: // Password
        return _password != null && _password!.length >= 6;
      default:
        return true;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Reset all data
  void reset() {
    _currentStep = 0;
    _selectedLanguage = null;
    _assessmentType = null;
    _name = null;
    _email = null;
    _password = null;
    _notificationsEnabled = false;

    // Reset database fields to defaults
    _fullName = null;
    _profilePictureUrl = 'https://res.cloudinary.com/diugsirlo/image/upload/v1759473921/download_zsyyia.png';
    _dateOfBirth = null;
    _gender = 'PREFER_NOT_TO_SAY';
    _nativeLanguage = 'vi';
    _targetLanguage = 'en';
    _proficiencyLevel = null;
    _learningGoals.clear();
    _dailyGoalMinutes = 15;
    _studyReminder = 'DAILY';
    _reminderTime = null;
    _timezone = 'Asia/Ho_Chi_Minh';
    _isEmailVerified = false;
    _isActive = true;
    
    notifyListeners();
  }

  // Mapping methods for database compatibility
  String? _mapExperienceToEnum(String? experience) {
    if (experience == null) return null;
    switch (experience.toLowerCase()) {
      case 'beginner':
        return 'BEGINNER';
      case 'elementary':
        return 'ELEMENTARY';
      case 'intermediate':
        return 'INTERMEDIATE';
      case 'upper_intermediate':
        return 'UPPER_INTERMEDIATE';
      case 'advanced':
        return 'ADVANCED';
      case 'proficient':
        return 'PROFICIENT';
      default:
        return 'BEGINNER';
    }
  }

  String _mapGoalToEnum(String goal) {
    switch (goal.toLowerCase()) {
      case 'connect':
        return 'CONNECT';
      case 'travel':
        return 'TRAVEL';
      case 'study':
      case 'academic':
        return 'STUDY';
      case 'entertainment':
        return 'ENTERTAINMENT';
      case 'career':
      case 'business':
        return 'CAREER';
      case 'hobby':
        return 'HOBBY';
      default:
        return 'ENTERTAINMENT';
    }
  }

  // Reverse mapping methods for backward compatibility
  String? _mapEnumToExperience(String? proficiencyEnum) {
    if (proficiencyEnum == null) return null;
    switch (proficiencyEnum) {
      case 'BEGINNER':
        return 'beginner';
      case 'ELEMENTARY':
        return 'elementary';
      case 'INTERMEDIATE':
        return 'intermediate';
      case 'UPPER_INTERMEDIATE':
        return 'upper_intermediate';
      case 'ADVANCED':
        return 'advanced';
      case 'PROFICIENT':
        return 'proficient';
      default:
        return 'beginner';
    }
  }

  List<String> _mapEnumToGoals(List<String> learningGoalEnums) {
    return learningGoalEnums.map((enumGoal) {
      switch (enumGoal) {
        case 'CONNECT':
          return 'connect';
        case 'TRAVEL':
          return 'travel';
        case 'STUDY':
          return 'study';
        case 'ENTERTAINMENT':
          return 'entertainment';
        case 'CAREER':
          return 'career';
        case 'HOBBY':
          return 'hobby';
        default:
          return 'entertainment';
      }
    }).toList();
  }

  String? _mapMinutesToDailyGoal(int minutes) {
    switch (minutes) {
      case 5:
        return 'casual';
      case 10:
        return 'regular';
      case 15:
        return 'serious';
      case 20:
        return 'intense';
      default:
        return 'serious';
    }
  }

  int _mapDailyGoalToMinutes(String? goal) {
    if (goal == null) return 15;
    switch (goal.toLowerCase()) {
      case 'casual':
      case '5':
        return 5;
      case 'regular':
      case '10':
        return 10;
      case 'serious':
      case '15':
        return 15;
      case 'intense':
      case '20':
        return 20;
      default:
        return 15;
    }
  }

  // Get user data for registration (database compatible)
  Map<String, dynamic> getUserData() {
    return {
      'email': _email,
      'fullName': _fullName ?? _name,
      'profilePictureUrl': _profilePictureUrl,
      'dateOfBirth': _dateOfBirth ?? DateTime.now().subtract(Duration(days: 365 * 20)), // Default 20 years old
      'gender': _gender,
      'nativeLanguage': _nativeLanguage,
      'targetLanguage': _targetLanguage,
      'proficiencyLevel': _proficiencyLevel ?? 'BEGINNER',
      'learningGoals': _learningGoals.isNotEmpty ? _learningGoals : ['PERSONAL'],
      'dailyGoalMinutes': _dailyGoalMinutes,
      'studyReminder': _studyReminder,
      'reminderTime': _reminderTime ?? '09:00', // Default 9:00 AM
      'timezone': _timezone,
      'isEmailVerified': _isEmailVerified,
      'isActive': _isActive,
      
      // Keep original fields for backward compatibility
      'password': _password,
      'selectedLanguage': _selectedLanguage,
      'assessmentType': _assessmentType,
      'notificationsEnabled': _notificationsEnabled,
    };
  }
}