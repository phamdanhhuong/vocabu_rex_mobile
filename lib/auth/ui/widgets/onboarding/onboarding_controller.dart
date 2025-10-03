import 'package:flutter/material.dart';

class OnboardingController extends ChangeNotifier {
  int _currentStep = 0;
  String? _selectedLanguage;
  String? _experienceLevel;
  List<String> _selectedGoals = [];
  String? _dailyGoal;
  String? _assessmentType;
  String? _name;
  String? _email;
  String? _password;
  bool _notificationsEnabled = false;

  // Additional fields for database compatibility (with hardcoded defaults)
  String? _fullName;
  String? _profilePictureUrl;
  DateTime? _dateOfBirth;
  String _gender = 'PREFER_NOT_TO_SAY'; // Default gender
  String _nativeLanguage = 'vi'; // Vietnamese as default
  String _targetLanguage = 'en'; // English as default
  String? _proficiencyLevel;
  List<String> _learningGoals = [];
  int _dailyGoalMinutes = 15; // Default 15 minutes
  String _studyReminder = 'DAILY'; // Default daily reminder
  String? _reminderTime;
  String _timezone = 'Asia/Ho_Chi_Minh'; // Default timezone
  bool _isEmailVerified = false;
  bool _isActive = true;

  // Getters
  int get currentStep => _currentStep;
  String? get selectedLanguage => _selectedLanguage;
  String? get experienceLevel => _experienceLevel;
  List<String> get selectedGoals => _selectedGoals;
  String? get dailyGoal => _dailyGoal;
  String? get assessmentType => _assessmentType;
  String? get name => _name;
  String? get email => _email;
  String? get password => _password;
  bool get notificationsEnabled => _notificationsEnabled;

  // Additional getters for database fields
  String? get fullName => _fullName ?? _name;
  String? get profilePictureUrl => _profilePictureUrl;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get gender => _gender;
  String get nativeLanguage => _nativeLanguage;
  String get targetLanguage => _targetLanguage;
  String? get proficiencyLevel => _proficiencyLevel ?? _mapExperienceToEnum(_experienceLevel);
  List<String> get learningGoals => _learningGoals.isNotEmpty ? _learningGoals : _mapSelectedGoalsToEnum(_selectedGoals);
  int get dailyGoalMinutes => _dailyGoalMinutes;
  String get studyReminder => _studyReminder;
  String? get reminderTime => _reminderTime;
  String get timezone => _timezone;
  bool get isEmailVerified => _isEmailVerified;
  bool get isActive => _isActive;

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
    _experienceLevel = level;
    _proficiencyLevel = _mapExperienceToEnum(level);
    notifyListeners();
  }

  void toggleGoal(String goal) {
    if (_selectedGoals.contains(goal)) {
      _selectedGoals.remove(goal);
    } else {
      _selectedGoals.add(goal);
    }
    _learningGoals = _mapSelectedGoalsToEnum(_selectedGoals);
    notifyListeners();
  }

  void setDailyGoal(String goal) {
    _dailyGoal = goal;
    _dailyGoalMinutes = _mapDailyGoalToMinutes(goal);
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

  // Validation
  bool canProceedFromStep(int step) {
    switch (step) {
      case 0: // Language selection
        return _selectedLanguage != null;
      case 1: // Experience level
        return _experienceLevel != null;
      case 2: // Learning goals
        return _selectedGoals.isNotEmpty;
      case 3: // Daily goal
        return _dailyGoal != null;
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
    _experienceLevel = null;
    _selectedGoals.clear();
    _dailyGoal = null;
    _assessmentType = null;
    _name = null;
    _email = null;
    _password = null;
    _notificationsEnabled = false;

    // Reset additional database fields
    _fullName = null;
    _profilePictureUrl = null;
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
      default:
        return 'BEGINNER';
    }
  }

  List<String> _mapSelectedGoalsToEnum(List<String> goals) {
    return goals.map((goal) {
      switch (goal.toLowerCase()) {
        case 'business':
        case 'career':
          return 'BUSINESS';
        case 'travel':
          return 'TRAVEL';
        case 'study':
        case 'academic':
          return 'ACADEMIC';
        case 'entertainment':
        case 'connect':
        case 'hobby':
          return 'PERSONAL';
        default:
          return 'PERSONAL';
      }
    }).toList();
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
      'dateOfBirth': _dateOfBirth,
      'gender': _gender,
      'nativeLanguage': _nativeLanguage,
      'targetLanguage': _targetLanguage,
      'proficiencyLevel': _proficiencyLevel ?? _mapExperienceToEnum(_experienceLevel),
      'learningGoals': _learningGoals.isNotEmpty ? _learningGoals : _mapSelectedGoalsToEnum(_selectedGoals),
      'dailyGoalMinutes': _dailyGoalMinutes,
      'studyReminder': _studyReminder,
      'reminderTime': _reminderTime,
      'timezone': _timezone,
      'isEmailVerified': _isEmailVerified,
      'isActive': _isActive,
      
      // Keep original fields for backward compatibility
      'password': _password,
      'selectedLanguage': _selectedLanguage,
      'experienceLevel': _experienceLevel,
      'selectedGoals': _selectedGoals,
      'dailyGoal': _dailyGoal,
      'assessmentType': _assessmentType,
      'notificationsEnabled': _notificationsEnabled,
    };
  }
}