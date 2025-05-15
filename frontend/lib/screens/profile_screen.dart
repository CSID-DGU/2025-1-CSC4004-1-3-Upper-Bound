import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _heightController = TextEditingController();
  final _upperArmController = TextEditingController();
  final _forearmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupNumericOnly(_heightController);
    _setupNumericOnly(_upperArmController);
    _setupNumericOnly(_forearmController);
  }

  void _setupNumericOnly(TextEditingController controller) {
    controller.addListener(() {
      final rawText = controller.text.replaceAll(RegExp(r'[^0-9]'), '');

      final displayText = rawText.isNotEmpty ? '${rawText}cm' : '';
      final selectionIndex = rawText.length;

      if (controller.text != displayText) {
        controller.value = TextEditingValue(
          text: displayText,
          selection: TextSelection.collapsed(offset: selectionIndex),
        );
      }
    });
  }

  String _getNumericValue(TextEditingController controller) {
    return controller.text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  void dispose() {
    _heightController.dispose();
    _upperArmController.dispose();
    _forearmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: const Text('내 정보', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            _buildInfoField('신장', _heightController),
            _buildInfoField('상완', _upperArmController),
            _buildInfoField('전완', _forearmController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final height = _getNumericValue(_heightController);
                final upper = _getNumericValue(_upperArmController);
                final fore = _getNumericValue(_forearmController);

                print("신장: $height");
                print("상완: $upper");
                print("전완: $fore");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('완료', style: TextStyle(color: Colors.black, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 16))),
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '숫자 입력',
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const Divider(thickness: 1),
      ],
    );
  }
}
