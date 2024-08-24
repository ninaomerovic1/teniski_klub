import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/pages/kreiranje_termina.dart';
import 'package:teniski_klub_projekat/pages/pocetna.dart';
import 'package:teniski_klub_projekat/pages/pregled_termina.dart';
import 'package:teniski_klub_projekat/pages/rezervisi_termin.dart';
import 'package:teniski_klub_projekat/widgets/prikaz_rezervacije.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<bool> _userStatusFuture;

  @override
  void initState() {
    super.initState();
    _userStatusFuture = _initializeUserStatus();
  }

  Future<bool> _initializeUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isAdmin = prefs.getBool('isAdmin') ?? false;

    // Inicijalizuj TabController nakon što dobiješ korisnički status
    _tabController = TabController(
      length: isAdmin ? 5 : 3,
      vsync: this,
    );

    return isAdmin;
  }


   Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Očisti sve podatke iz SharedPreferences

     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uspešno ste se odjavili.'),
        duration: Duration(seconds: 2),
      ),
    );

    // Vrati korisnika na stranicu za prijavu
    Navigator.pushNamed(context, '/signin');
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Teniski Klub'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: FutureBuilder<bool>(
            future: _userStatusFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Greška pri učitavanju'));
              } else {
                bool isAdmin = snapshot.data ?? false;

                return Align(
                  alignment: Alignment.topLeft,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Color.fromARGB(255, 4, 113, 7),
                    labelColor: Color.fromARGB(255, 4, 113, 7), // Boja teksta za odabrane tabove
                    unselectedLabelColor: Colors.black,
                    isScrollable: true, // Omogućava skrolovanje tabova ako ne staju u jedan red
                    tabs: isAdmin
                        ? [
                            Tab(text: 'Početna'),
                            Tab(text: 'Rezerviši termin'),
                            Tab(text: 'Pregled termina'),
                            Tab(text: 'Kreiraj termin'),
                            Tab(text: 'Pregled rezervacija'),
                          ]
                        : [
                            Tab(text: 'Početna'),
                            Tab(text: 'Rezerviši termin'),
                            Tab(text: 'Pregled termina'),
                          ],
                  ),
                );
              }
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, 
              // Implement logout functionality here
              
            
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _userStatusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Greška pri učitavanju'));
          } else {
            bool isAdmin = snapshot.data ?? false;

            return TabBarView(
              controller: _tabController,
              children: isAdmin
                  ? [
                      Pocetna(),
                      Rezervisi(),
                      Center(
                          child: Text('Pregled Termina',
                              style: TextStyle(fontSize: 24))),
                      KreirajTermin(),
                      Center(
                          child: Text('Pregled Rezervacija',
                              style: TextStyle(fontSize: 24))),
                    ]
                  : [
                      Pocetna(),
                      Rezervisi(),
                      PregledTermina(),
                    ],
            );
          }
        },
      ),
    );
  }
}
