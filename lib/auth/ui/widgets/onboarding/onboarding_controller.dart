import 'package:flutter/material.dart';

/// Simplified onboarding controller for config-driven onboarding
class OnboardingController extends ChangeNotifier {
  // Navigation
  int _currentStep = 0;
  
  // Store values for each step by step ID
  final Map<String, dynamic> _stepValues = {};
  
  // Getters
  int get currentStep => _currentStep;
  Map<String, dynamic> get stepValues => Map.unmodifiable(_stepValues);
  
  // Navigation methods
  void nextStep() {
    _currentStep++;
    notifyListeners();
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
  
  // Value management
  void setStepValue(String stepId, dynamic value) {
    _stepValues[stepId] = value;
    notifyListeners();
  }
  
  dynamic getStepValue(String stepId) {
    return _stepValues[stepId];
  }
  
  // Validation
  bool hasValueForStep(String stepId) {
    return _stepValues.containsKey(stepId) && _stepValues[stepId] != null;
  }
  
  // Get user data for registration
  Map<String, dynamic> getUserData() {
    return {
      'email': _stepValues['email'],
      'password': _stepValues['password'],
      'fullName': _stepValues['name'],
      'profilePictureUrl': 'https://res.cloudinary.com/diugsirlo/image/upload/v1759473921/download_zsyyia.png',
      'dateOfBirth': DateTime.now().subtract(const Duration(days: 365 * 20)), // Default 20 years old
      'gender': 'PREFER_NOT_TO_SAY',
      'nativeLanguage': 'vi',
      'targetLanguage': _stepValues['language'] ?? 'en',
      'proficiencyLevel': _stepValues['proficiency_level'] ?? 'BEGINNER',
      'learningGoals': _stepValues['learning_goals'] ?? ['PERSONAL'],
      'dailyGoalMinutes': _stepValues['daily_goal'] ?? 15,
      'studyReminder': 'DAILY',
      'reminderTime': '09:00',
      'timezone': 'Asia/Ho_Chi_Minh',
      'isEmailVerified': false,
      'isActive': true,
      
      // Additional onboarding data
      'assessmentType': _stepValues['assessment'],
    };
  }
  
  // Reset all data
  void reset() {
    _currentStep = 0;
    _stepValues.clear();
    notifyListeners();
  }
}
