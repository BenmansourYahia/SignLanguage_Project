import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  // ASL Alphabet data (A-Z only)
  static const List<Map<String, String>> aslAlphabet = [
    {'letter': 'A', 'description': 'Closed fist, thumb on side'},
    {'letter': 'B', 'description': 'Flat hand, thumb across palm'},
    {'letter': 'C', 'description': 'Curved hand like letter C'},
    {'letter': 'D', 'description': 'Index up, other fingers touch thumb'},
    {'letter': 'E', 'description': 'Fingers curled, thumb across'},
    {'letter': 'F', 'description': 'OK sign (thumb and index circle)'},
    {'letter': 'G', 'description': 'Index and thumb pointing sideways'},
    {'letter': 'H', 'description': 'Index and middle pointing sideways'},
    {'letter': 'I', 'description': 'Pinky finger up, fist closed'},
    {'letter': 'J', 'description': 'Pinky up, draw J in air'},
    {'letter': 'K', 'description': 'Index up, middle out, thumb between'},
    {'letter': 'L', 'description': 'Thumb and index form L shape'},
    {'letter': 'M', 'description': 'Thumb under first 3 fingers'},
    {'letter': 'N', 'description': 'Thumb under first 2 fingers'},
    {'letter': 'O', 'description': 'Fingers form circle (like OK)'},
    {'letter': 'P', 'description': 'Like K but pointing down'},
    {'letter': 'Q', 'description': 'Like G but pointing down'},
    {'letter': 'R', 'description': 'Index and middle crossed'},
    {'letter': 'S', 'description': 'Fist with thumb in front'},
    {'letter': 'T', 'description': 'Thumb between index and middle'},
    {'letter': 'U', 'description': 'Index and middle up together'},
    {'letter': 'V', 'description': 'Peace sign (index and middle)'},
    {'letter': 'W', 'description': 'Index, middle, ring up'},
    {'letter': 'X', 'description': 'Index bent like hook'},
    {'letter': 'Y', 'description': 'Thumb and pinky out (hang loose)'},
    {'letter': 'Z', 'description': 'Draw Z in air with index'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASL Alphabet Guide'),
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.blueAccent.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blueAccent.shade200),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Learn the 26 ASL alphabet signs (A-Z)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Alphabet Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: aslAlphabet.length,
                itemBuilder: (context, index) {
                  final sign = aslAlphabet[index];
                  return Card(
                    elevation: 4,
                    color: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Letter
                          Text(
                            sign['letter']!,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent.shade200,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Divider
                          Container(
                            width: 40,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Description
                          Text(
                            sign['description']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
