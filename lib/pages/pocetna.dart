import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/widgets/vremenska_prognoza.dart';

class Pocetna extends StatefulWidget {
  @override
  _PocetnaState createState() => _PocetnaState();
}

class _PocetnaState extends State<Pocetna> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  PageController _pageController =
      PageController(); // Inicijalizacija PageController-a

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose(); // Oslobađanje resursa PageController-a
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showImageDialog(int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(12), // Zaobljene ivice
            ),
            width: MediaQuery.of(context).size.width * 0.8, // Širina dijaloga
            height: MediaQuery.of(context).size.height * 0.6, // Visina dijaloga
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: 5,
                  controller: _pageController, // Postavljanje PageController-a
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Image.asset(
                          'assets/tenis${index + 1}.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    setState(
                        () {}); // Osvežavanje stanja kada se stranica menja
                  },
                ),
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon:
                        Icon(Icons.arrow_back, color: Colors.orange, size: 30),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward,
                        color: Colors.orange, size: 30),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/reketi.png'),
                scale: 8.0,
                repeat: ImageRepeat.repeat,
                fit: BoxFit.none,
              ),
            ),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // Širina velikog kontejnera
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Dobrodošli',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 4, 113, 7),
                              ),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Ovo je početna stranica aplikacije za rezervaciju termina. Izaberite jednu od opcija u meniju iznad kako biste nastavili.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 370,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Broj kolona
                            crossAxisSpacing: 0, // Razmak između kolona
                            mainAxisSpacing: 0, // Razmak između redova
                          ),
                          itemCount: 5, // Broj slika
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _showImageDialog(index),
                              child: ClipRRect(
                                child: Image.asset(
                                  'assets/tenis${index + 1}.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: _toggleExpand,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _isExpanded ? 250 : 60,
                height: _isExpanded ? 250 : 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: _isExpanded
                    ? Center(
                        child: VremenskaPrognozaWidget(
                          latitude: 44.7866, // Latitude za Beograd
                          longitude: 20.4489, // Longitude za Beograd
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.wb_sunny,
                          color: Colors.orange,
                          size: 30,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
