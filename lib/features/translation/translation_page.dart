import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _inputController = TextEditingController();
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(
    confidenceThreshold: 0.5,
  );

  String _translatedText = '';
  String _detectedLanguage = '';
  bool _isTranslating = false;
  String _errorMessage = '';

  // Popular languages for tourists in Berlin
  final List<Map<String, String>> _popularLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'it', 'name': 'Italian', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Portuguese', 'flag': '🇵🇹'},
    {'code': 'ru', 'name': 'Russian', 'flag': '🇷🇺'},
    {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': 'Korean', 'flag': '🇰🇷'},
    {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳'},
    {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇦'},
    {'code': 'tr', 'name': 'Turkish', 'flag': '🇹🇷'},
    {'code': 'nl', 'name': 'Dutch', 'flag': '🇳🇱'},
    {'code': 'pl', 'name': 'Polish', 'flag': '🇵🇱'},
    {'code': 'sv', 'name': 'Swedish', 'flag': '🇸🇪'},
    {'code': 'da', 'name': 'Danish', 'flag': '🇩🇰'},
    {'code': 'no', 'name': 'Norwegian', 'flag': '🇳🇴'},
    {'code': 'fi', 'name': 'Finnish', 'flag': '🇫🇮'},
    {'code': 'cs', 'name': 'Czech', 'flag': '🇨🇿'},
    {'code': 'hu', 'name': 'Hungarian', 'flag': '🇭🇺'},
  ];

  String _sourceLanguage = 'en';
  String _targetLanguage = 'de';

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _languageIdentifier.close();
    super.dispose();
  }

  void _onTextChanged() {
    if (_inputController.text.isNotEmpty) {
      _detectLanguage();
    } else {
      setState(() {
        _detectedLanguage = '';
        _translatedText = '';
        _errorMessage = '';
      });
    }
  }

  Future<void> _detectLanguage() async {
    try {
      final String languageCode = await _languageIdentifier.identifyLanguage(
        _inputController.text,
      );
      setState(() {
        _detectedLanguage = languageCode;
        // Only update source language if it's a valid language in our list
        if (_detectedLanguage != 'und' &&
            _popularLanguages.any(
              (lang) => lang['code'] == _detectedLanguage,
            )) {
          _sourceLanguage = _detectedLanguage;
        }
      });
    } catch (e) {
      // Language detection failed, keep current source language
    }
  }

  Future<void> _translateText() async {
    if (_inputController.text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _errorMessage = '';
    });

    try {
      // Use LibreTranslate API (free and open source)
      final url = Uri.parse('https://libretranslate.de/translate');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': _inputController.text,
          'source': _sourceLanguage,
          'target': _targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['translatedText'] as String;

        setState(() {
          _translatedText = translatedText;
          _isTranslating = false;
        });
      } else {
        // Fallback to Google Translate API
        await _translateWithGoogleAPI();
      }
    } catch (e) {
      // If LibreTranslate fails, try Google Translate
      try {
        await _translateWithGoogleAPI();
      } catch (e2) {
        setState(() {
          _errorMessage = 'Translation failed: ${e2.toString()}';
          _isTranslating = false;
        });
      }
    }
  }

  Future<void> _translateWithGoogleAPI() async {
    final url = Uri.parse(
      'https://translate.googleapis.com/translate_a/single',
    );

    final response = await http.get(
      url.replace(
        queryParameters: {
          'client': 'gtx',
          'sl': _sourceLanguage,
          'tl': _targetLanguage,
          'dt': 't',
          'q': _inputController.text,
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translatedText = data[0][0][0] as String;

      setState(() {
        _translatedText = translatedText;
        _isTranslating = false;
      });
    } else {
      throw Exception('Translation failed');
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      _translatedText = '';
      _errorMessage = '';
    });
  }

  void _clearText() {
    setState(() {
      _inputController.clear();
      _translatedText = '';
      _detectedLanguage = '';
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A8A),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Smart Translator',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Selection
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLanguageSelector(
                                    value: _sourceLanguage,
                                    onChanged: (value) {
                                      setState(() {
                                        _sourceLanguage = value!;
                                        _translatedText = '';
                                        _errorMessage = '';
                                      });
                                    },
                                    label: 'From',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1E3A8A,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: _swapLanguages,
                                    icon: const Icon(
                                      Icons.swap_horiz_rounded,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildLanguageSelector(
                                    value: _targetLanguage,
                                    onChanged: (value) {
                                      setState(() {
                                        _targetLanguage = value!;
                                        _translatedText = '';
                                        _errorMessage = '';
                                      });
                                    },
                                    label: 'To',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                        // Detected Language Indicator
                        if (_detectedLanguage.isNotEmpty &&
                            _detectedLanguage != 'und')
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.language_rounded,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Detected: ${_getLanguageName(_detectedLanguage)}',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Text Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _inputController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Enter text to translate',
                        hintText: 'Type or paste text here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon:
                            _inputController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: _clearText,
                                  color: const Color(0xFF6B7280),
                                )
                                : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Translate Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed:
                          _inputController.text.isEmpty || _isTranslating
                              ? null
                              : _translateText,
                      icon:
                          _isTranslating
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(Icons.translate_rounded, size: 24),
                      label: Text(
                        _isTranslating ? 'Translating...' : 'Translate',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF1E3A8A).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // Error Message
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFDC2626),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Translation Result
                  if (_translatedText.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Translation',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const Spacer(),
                              // Copy functionality removed - not implemented
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _translatedText,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Popular Phrases Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_rounded,
                              color: Color(0xFFF59E0B),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Useful Phrases',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPhraseCard('Hello', 'Hallo', '🇩🇪'),
                        _buildPhraseCard('Thank you', 'Danke', '🇩🇪'),
                        _buildPhraseCard('Goodbye', 'Auf Wiedersehen', '🇩🇪'),
                        _buildPhraseCard('Where is...?', 'Wo ist...?', '🇩🇪'),
                        _buildPhraseCard('How much?', 'Wie viel?', '🇩🇪'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector({
    required String value,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    // Ensure the value exists in the language list
    final validValue =
        _popularLanguages.any((lang) => lang['code'] == value) ? value : 'en';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: validValue,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            menuMaxHeight: 300,
            isExpanded: true,
            items:
                _popularLanguages.map((language) {
                  return DropdownMenuItem<String>(
                    value: language['code'],
                    child: Row(
                      children: [
                        Text(language['flag']!),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            language['name']!,
                            style: GoogleFonts.inter(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhraseCard(String english, String german, String flag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  english,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  german,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Text-to-speech functionality removed - not implemented
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    final language = _popularLanguages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'code': code, 'name': code.toUpperCase()},
    );
    return language['name']!;
  }
}
