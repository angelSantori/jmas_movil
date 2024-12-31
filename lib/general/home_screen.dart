import 'package:flutter/material.dart';
import 'package:jmas_movil/controllers/auth_service.dart';
import 'package:jmas_movil/general/login_screen.dart';
import 'package:jmas_movil/movimientos/entradas/add_entrada_screen.dart';
import 'package:jmas_movil/movimientos/salidas/add_salida_screen.dart';
import 'package:jmas_movil/productos/list_producto_screen.dart';
import 'package:jmas_movil/widgets/componentes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? _userName;

  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final decodeToken = await _authService.decodeToken();
    setState(() {
      _userName = decodeToken?['sub'];
    });
  }

  void _logOut() {
    _authService.deleteToken();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  final List<Widget> _pages = [
    const Center(
      child: Text('Panalla principal'),
    ),
    const ListProductoScreen(),
    const AddEntradaScreen(),
    const AddSalidaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.blue.shade900,
          child: Column(
            children: <Widget>[
              //Encabezado
              Container(
                height: 80,
                alignment: Alignment.center,
                color: Colors.blue.shade700,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'JMAS',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    if (_userName != null)
                      Text(
                        _userName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ],
                ),
              ),

              //Menu
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //Pantalla pinripal
                      ListTile(
                        title: const Row(
                          children: [
                            Icon(
                              Icons.home,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Principal',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPageIndex = 0;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      //Producto
                      CustomExpansionTile(
                        title: 'Productos',
                        icon: Icons.store,
                        children: [
                          CustomListTile(
                            title: 'Lista de productos',
                            icon: Icons.list_alt_rounded,
                            onTap: () {
                              setState(() {
                                _selectedPageIndex = 1;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),

                      //Movimientos
                      CustomExpansionTile(
                        title: 'Movimientos',
                        icon: Icons.folder_copy_sharp,
                        children: [
                          SubCustomExpansionTile(
                            title: 'Entradas',
                            icon: Icons.note_add_outlined,
                            children: [
                              CustomListTile(
                                title: 'Agregar entrada',
                                icon: Icons.move_up,
                                onTap: () {
                                  setState(() {
                                    _selectedPageIndex = 2;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          SubCustomExpansionTile(
                            title: 'Salidas',
                            icon: Icons.outgoing_mail,
                            children: [
                              CustomListTile(
                                title: 'Agregar salida',
                                icon: Icons.move_down,
                                onTap: () {
                                  setState(() {
                                    _selectedPageIndex = 3;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              //Salir / Logout
              ListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.redAccent.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Salir',
                      style: TextStyle(
                        color: Colors.redAccent.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmar cierre de seisón.'),
                        content: const Text(
                            '¿Estás seguro de que deseas cerrar sesión?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Salir'),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    _logOut();
                  }
                },
              ),
            ],
          ),
        ),
        body: _pages[_selectedPageIndex],
      ),
    );
  }
}
