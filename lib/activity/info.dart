import 'package:flutter/material.dart';

class AboutDepartmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Department"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.translate(
                  offset: Offset(2.5, 0.0),
                  child: Image.asset(
                    'assets/images/anft_dept-removebg-preview.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "The Department of Applied Nutrition and Food Technology (ANFT) offering Bachelor of Science (B.Sc) Honours degree program at undergraduate level and Master of Science (M.Sc) with/without thesis degree at post-graduate level in the field of Applied Nutrition and Food Technology.\n\nThis Department born on 1998-1999 academic session is one of the pioneers in the respective field. The graduates from this department serving as Dietician at various renowned hospitals and privet practice center, as Nutritionist at various national as well as international health providing organizations, research organizations, as Food Scientist at national and international food safety authority, as production, product development & quality control/assurance officer at various national & International food processing, preservation industries.\n\nThe department also offer M.Phil and PhD degree field of Food Microbiology, Food Science, Molecular Nutrition, Epidemiology, Clinical Nutrition, Nutraceuticals etc. \n\nOur mission to build a healthy nation through dissemination of Nutrition and Food Science knowledge by experts and graduates of our department. The department also offer Evening Masters Program (MNSFT).",
                style: (TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 55, 53, 53))),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
