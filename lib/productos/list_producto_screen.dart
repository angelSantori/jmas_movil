import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jmas_movil/controllers/productos_controller.dart';
import 'package:jmas_movil/productos/details_producto_screen.dart';

class ListProductoScreen extends StatefulWidget {
  const ListProductoScreen({super.key});

  @override
  State<ListProductoScreen> createState() => _ListProductoScreenState();
}

class _ListProductoScreenState extends State<ListProductoScreen> {
  final ProductosController _productosController = ProductosController();
  final TextEditingController _searchController = TextEditingController();

  List<Productos> _allProductos = [];
  List<Productos> _filteredProductos = [];

  @override
  void initState() {
    super.initState();
    _loadProductos();
    _searchController.addListener(_filterProductos);
  }

  Future<void> _loadProductos() async {
    try {
      final productos = await _productosController.listProductos();
      setState(() {
        _allProductos = productos;
        _filteredProductos = productos;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
    }
  }

  void _filterProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProductos = _allProductos.where((producto) {
        final descripcion = producto.producto_Descripcion?.toLowerCase() ?? '';
        final id = producto.id_Producto.toString();
        return descripcion.contains(query) || id.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de productos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por descripción o ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredProductos.isEmpty
                ? const Center(
                    child:
                        Text('No hay productos que coincidan con la búsqueda'),
                  )
                : ListView.builder(
                    itemCount: _filteredProductos.length,
                    itemBuilder: (context, index) {
                      final producto = _filteredProductos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: producto.producto_ImgBase64 != null &&
                                    producto.producto_ImgBase64!.isNotEmpty
                                ? Image.memory(
                                    base64Decode(producto.producto_ImgBase64!),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/sinFoto.jpg',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          title: Text(
                            producto.producto_Descripcion!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Clave: ${producto.id_Producto}'),
                              Text('Costo: \$${producto.producto_Costo}'),
                              Text(
                                'Existencias: ${producto.producto_Existencia} ${producto.producto_UMedida}',
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsProductoScreen(producto: producto),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
