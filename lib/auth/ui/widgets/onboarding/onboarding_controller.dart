import 'package:flutter/material.dart';

class OnboardingController extends ChangeNotifier {
  int _currentStep = 0;
  String? _selectedLanguage;
  String? _experienceLevel;
  List<String> _selectedGoals = [];
  String? _dailyGoal;
  String? _name;
  String? _email;
  String? _password;
  bool _notificationsEnabled = false;

  // Getters
  int get currentStep => _currentStep;
  String? get selectedLanguage => _selectedLanguage;
  String? get experienceLevel => _experienceLevel;
  List<String> get selectedGoals => _selectedGoals;
  String? get dailyGoal => _dailyGoal;
  String? get name => _name;
  String? get email => _email;
  String? get password => _password;
  bool get notificationsEnabled => _notificationsEnabled;

  // Navigation methods
  void nextStep() {
    if (_currentStep < 7) {
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
    notifyListeners();
  }

  void toggleGoal(String goal) {
    if (_selectedGoals.contains(goal)) {
      _selectedGoals.remove(goal);
    } else {
      _selectedGoals.add(goal);
    }
    notifyListeners();
  }

  void setDailyGoal(String goal) {
    _dailyGoal = goal;
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
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
      case 4: // Name
        return _name != null && _name!.isNotEmpty;
      case 5: // Email
        return _email != null && _email!.isNotEmpty && _isValidEmail(_email!);
      case 6: // Password
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
    _name = null;
    _email = null;
    _password = null;
    _notificationsEnabled = false;
    notifyListeners();
  }

  // Get user data for registration
  Map<String, dynamic> getUserData() {
    return {
      'name': _name,
      'email': _email,
      'password': _password,
      'selectedLanguage': _selectedLanguage,
      'experienceLevel': _experienceLevel,
      'learningGoals': _selectedGoals,
      'dailyGoal': _dailyGoal,
      'notificationsEnabled': _notificationsEnabled,
    };
  }
}