import 'package:flutter/material.dart';

class PlantControlPreset {
  final bool waterPumps;
  final double waterPumpsIntensity;
  final String waterPumpsStatus;

  final bool growLights;
  final double growLightsIntensity;
  final String growLightsStatus;

  final bool ventilation;
  final double ventilationIntensity;
  final String ventilationStatus;

  final bool nutrientDosing;
  final double nutrientDosingIntensity;
  final String nutrientDosingStatus;

  final double targetTemp;

  const PlantControlPreset({
    required this.waterPumps,
    required this.waterPumpsIntensity,
    required this.waterPumpsStatus,
    required this.growLights,
    required this.growLightsIntensity,
    required this.growLightsStatus,
    required this.ventilation,
    required this.ventilationIntensity,
    required this.ventilationStatus,
    required this.nutrientDosing,
    required this.nutrientDosingIntensity,
    required this.nutrientDosingStatus,
    required this.targetTemp,
  });
}

class ControlScreen extends StatefulWidget {
  final String initialPlant;
  final ValueChanged<String>? onPlantChanged;

  const ControlScreen({
    super.key,
    this.initialPlant = 'Strawberry',
    this.onPlantChanged,
  });

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late String _selectedPlant;
  bool _waterPumps = true;
  double _waterPumpsIntensity = 0.85;

  bool _growLights = true;
  double _growLightsIntensity = 1.0;

  bool _ventilation = false;
  double _ventilationIntensity = 0.0;

  bool _nutrientDosing = true;
  double _nutrientDosingIntensity = 0.5;

  double _targetTemp = 22.5;

  // Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF4C4C4C);
  static const Color greenDark = Color(0xFF28824D);
  static const Color green2 = Color(0xFF3CA768);
  static const Color lightGray = Color(0xFFECECEC);
  static const Color darkGrey = Color(0xFF838383);
  static const Color blue2 = Color(0xFF4BB4D6);

  final List<String> _plants = [
    'Strawberry',
    'Butter Lettuce',
    'Basil',
    'Tomato',
    'Blueberries',
  ];

  static const Map<String, PlantControlPreset> _presets = {
    'Strawberry': PlantControlPreset(
      waterPumps: true,
      waterPumpsIntensity: 0.85,
      waterPumpsStatus: 'Operating normally',
      growLights: true,
      growLightsIntensity: 1.0,
      growLightsStatus: 'Scheduled to turn off at 20:00',
      ventilation: false,
      ventilationIntensity: 0.0,
      ventilationStatus: 'Currently idle',
      nutrientDosing: true,
      nutrientDosingIntensity: 0.5,
      nutrientDosingStatus: 'Last dose: 2 hrs ago',
      targetTemp: 22.5,
    ),
    'Butter Lettuce': PlantControlPreset(
      waterPumps: true,
      waterPumpsIntensity: 0.90,
      waterPumpsStatus: 'Operating normally',
      growLights: true,
      growLightsIntensity: 0.80,
      growLightsStatus: 'Eco mode active',
      ventilation: true,
      ventilationIntensity: 0.40,
      ventilationStatus: 'Running low speed',
      nutrientDosing: true,
      nutrientDosingIntensity: 0.70,
      nutrientDosingStatus: 'Last dose: 1 hr ago',
      targetTemp: 19.0,
    ),
    'Basil': PlantControlPreset(
      waterPumps: true,
      waterPumpsIntensity: 0.75,
      waterPumpsStatus: 'Operating normally',
      growLights: true,
      growLightsIntensity: 0.90,
      growLightsStatus: 'Scheduled to turn off at 22:00',
      ventilation: true,
      ventilationIntensity: 0.30,
      ventilationStatus: 'Gentle breeze active',
      nutrientDosing: true,
      nutrientDosingIntensity: 0.60,
      nutrientDosingStatus: 'Last dose: 30 mins ago',
      targetTemp: 24.0,
    ),
    'Tomato': PlantControlPreset(
      waterPumps: true,
      waterPumpsIntensity: 0.95,
      waterPumpsStatus: 'High flow mode',
      growLights: true,
      growLightsIntensity: 0.95,
      growLightsStatus: 'Full spectrum active',
      ventilation: true,
      ventilationIntensity: 0.50,
      ventilationStatus: 'Running medium speed',
      nutrientDosing: true,
      nutrientDosingIntensity: 0.80,
      nutrientDosingStatus: 'Last dose: 3 hrs ago',
      targetTemp: 26.0,
    ),
    'Blueberries': PlantControlPreset(
      waterPumps: true,
      waterPumpsIntensity: 0.80,
      waterPumpsStatus: 'Operating normally',
      growLights: true,
      growLightsIntensity: 0.70,
      growLightsStatus: 'Scheduled to turn off at 19:00',
      ventilation: false,
      ventilationIntensity: 0.0,
      ventilationStatus: 'Currently idle',
      nutrientDosing: false,
      nutrientDosingIntensity: 0.0,
      nutrientDosingStatus: 'System suspended',
      targetTemp: 21.0,
    ),
  };

  @override
  void initState() {
    super.initState();
    _selectedPlant = widget.initialPlant;
    _loadPreset();
  }

  void _loadPreset() {
    final preset = _presets[_selectedPlant] ?? _presets['Strawberry']!;
    _waterPumps = preset.waterPumps;
    _waterPumpsIntensity = preset.waterPumpsIntensity;
    _growLights = preset.growLights;
    _growLightsIntensity = preset.growLightsIntensity;
    _ventilation = preset.ventilation;
    _ventilationIntensity = preset.ventilationIntensity;
    _nutrientDosing = preset.nutrientDosing;
    _nutrientDosingIntensity = preset.nutrientDosingIntensity;
    _targetTemp = preset.targetTemp;
  }

  @override
  Widget build(BuildContext context) {
    final preset = _presets[_selectedPlant] ?? _presets['Strawberry']!;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Actuator Control',
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Greenhouse settings & targets',
                    style: TextStyle(
                      color: darkGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 145,
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F9F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: green2.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPlant,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: greenDark,
                        size: 20,
                      ),
                      dropdownColor: white,
                      borderRadius: BorderRadius.circular(8),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: black,
                      ),
                      items: _plants.map((String plant) {
                        return DropdownMenuItem<String>(
                          value: plant,
                          child: Text(plant),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPlant = newValue;
                            _loadPreset();
                          });
                          if (widget.onPlantChanged != null) {
                            widget.onPlantChanged!(newValue);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSwitchCard(
              title: 'Water Pumps',
              subtitle: preset.waterPumpsStatus,
              value: _waterPumps,
              onChanged: (val) => setState(() {
                _waterPumps = val;
                if (val && _waterPumpsIntensity == 0.0) {
                  _waterPumpsIntensity = 0.5;
                }
              }),
              icon: Icons.water_drop_rounded,
              color: blue2,
              intensity: _waterPumpsIntensity,
              onIntensityChanged: (val) => setState(() => _waterPumpsIntensity = val),
            ),
            _buildSwitchCard(
              title: 'Grow Lights (Spectrum A)',
              subtitle: preset.growLightsStatus,
              value: _growLights,
              onChanged: (val) => setState(() {
                _growLights = val;
                if (val && _growLightsIntensity == 0.0) {
                  _growLightsIntensity = 0.5;
                }
              }),
              icon: Icons.lightbulb_rounded,
              color: greenDark,
              intensity: _growLightsIntensity,
              onIntensityChanged: (val) => setState(() => _growLightsIntensity = val),
            ),
            _buildSwitchCard(
              title: 'Ventilation Fans',
              subtitle: preset.ventilationStatus,
              value: _ventilation,
              onChanged: (val) => setState(() {
                _ventilation = val;
                if (val && _ventilationIntensity == 0.0) {
                  _ventilationIntensity = 0.5;
                }
              }),
              icon: Icons.air_rounded,
              color: darkGrey,
              intensity: _ventilationIntensity,
              onIntensityChanged: (val) => setState(() => _ventilationIntensity = val),
            ),
            _buildSwitchCard(
              title: 'Nutrient Dosing Pump',
              subtitle: preset.nutrientDosingStatus,
              value: _nutrientDosing,
              onChanged: (val) => setState(() {
                _nutrientDosing = val;
                if (val && _nutrientDosingIntensity == 0.0) {
                  _nutrientDosingIntensity = 0.5;
                }
              }),
              icon: Icons.science_rounded,
              color: Colors.purple.shade400,
              intensity: _nutrientDosingIntensity,
              onIntensityChanged: (val) => setState(() => _nutrientDosingIntensity = val),
            ),

            const SizedBox(height: 24),
            const Text(
              'Climate Target',
              style: TextStyle(
                color: black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            _buildSliderCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
    required double intensity,
    required ValueChanged<double> onIntensityChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightGray, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: value ? color.withOpacity(0.12) : lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: value ? color : darkGrey, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: darkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: color,
                activeTrackColor: color.withOpacity(0.3),
              )
            ],
          ),
          if (value) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Intensity',
                  style: TextStyle(
                    fontSize: 11,
                    color: darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: color,
                      inactiveTrackColor: lightGray,
                      thumbColor: color,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
                    child: Slider(
                      value: intensity,
                      min: 0.0,
                      max: 1.0,
                      onChanged: onIntensityChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(intensity * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildSliderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightGray, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target Temperature',
                style: TextStyle(
                  color: darkGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                '${_targetTemp.toStringAsFixed(1)} °C',
                style: const TextStyle(
                  color: greenDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: green2,
              inactiveTrackColor: lightGray,
              thumbColor: greenDark,
              overlayColor: greenDark.withOpacity(0.1),
            ),
            child: Slider(
              value: _targetTemp,
              min: 15.0,
              max: 30.0,
              divisions: 30,
              onChanged: (val) {
                setState(() {
                  _targetTemp = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
