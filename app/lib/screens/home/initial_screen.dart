import 'package:flutter/material.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top:90,left:20,right: 20,bottom: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1st child:logo
              Center(
                child: CircleAvatar(
                  radius: 120,
                  child: Icon(Icons.document_scanner_rounded, size: 80),
                ),
              ),

              // 2nd child:message
              SizedBox(height: 30),
              Center(
                child: Text(
                  'Scan,Organize and Secure',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Your Documents.',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // 3rd child:4dots
              SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dot 1 (active)
                  Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Dot 2
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Dot 3
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Dot 4
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              // 4th child:buttons
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 65,
                      child: ElevatedButton(
                        
                        onPressed: () {},
                        child: const Text('Login'),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: SizedBox(
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('join now'),
                      ),
                    ),
                  ),
                ],
              ),

              // 5th child:coninue
              SizedBox(height: 30),
              Center(child: Text('continue as a guest')),
            ],
          ),
        ),
      ),
    );
  }
}
